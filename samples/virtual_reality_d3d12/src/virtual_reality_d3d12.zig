const std = @import("std");
const OpenVR = @import("zopenvr");

const zglfw = @import("zglfw");
const zwin32 = @import("zwin32");
const zd3d12 = @import("zd3d12");
const w32 = zwin32.w32;
const d3d12 = zwin32.d3d12;
const dxgi = zwin32.dxgi;
const zgui = @import("zgui");

const content_dir = @import("build_options").content_dir;
const window_title = "zig-gamedev: virtual reality (d3d12)";

const Surface = struct {
    window: *zglfw.Window,
    gctx: zd3d12.GraphicsContext,
    scale_factor: f32,
    framebuffer_size: [2]i32,

    const Self = @This();

    fn init(allocator: std.mem.Allocator, width: i32, height: i32, monitor_video_mode: ?MonitorVideoMode) !Self {
        var window_width: i32 = width;
        var window_height: i32 = height;
        var monitor: ?*zglfw.Monitor = null;
        if (monitor_video_mode) |mvm| {
            monitor = mvm.monitor;
            window_width = mvm.video_mode.width;
            window_height = mvm.video_mode.height;
            zglfw.windowHintTyped(.red_bits, mvm.video_mode.red_bits);
            zglfw.windowHintTyped(.green_bits, mvm.video_mode.green_bits);
            zglfw.windowHintTyped(.blue_bits, mvm.video_mode.blue_bits);
            zglfw.windowHintTyped(.refresh_rate, mvm.video_mode.refresh_rate);
        }
        zglfw.windowHintTyped(.client_api, .no_api);
        zglfw.windowHintTyped(.maximized, true);
        const window = try zglfw.Window.create(window_width, window_height, window_title, monitor);

        const win32_window = zglfw.getWin32Window(window) orelse return error.FailedToGetWin32Window;
        const gctx = zd3d12.GraphicsContext.init(allocator, win32_window);

        zgui.init(allocator);
        zgui.plot.init();

        {
            const cbv_srv = gctx.cbv_srv_uav_gpu_heaps[0];
            zgui.backend.init(
                window,
                gctx.device,
                zd3d12.GraphicsContext.max_num_buffered_frames,
                @intFromEnum(dxgi.FORMAT.R8G8B8A8_UNORM),
                cbv_srv.heap.?,
                @bitCast(cbv_srv.base.cpu_handle),
                @bitCast(cbv_srv.base.gpu_handle),
            );
        }

        const scale_factor = scale_factor: {
            const scale = window.getContentScale();
            break :scale_factor @max(scale[0], scale[1]);
        };
        {
            _ = zgui.io.addFontFromFile(
                content_dir ++ "Roboto-Medium.ttf",
                std.math.floor(16.0 * scale_factor),
            );

            zgui.getStyle().scaleAllSizes(scale_factor);
        }
        return .{
            .window = window,
            .gctx = gctx,
            .scale_factor = scale_factor,
            .framebuffer_size = [_]i32{ window_width, window_height },
        };
    }

    fn reinit(self: *Self, allocator: std.mem.Allocator, monitor_video_mode: ?MonitorVideoMode) !void {
        self.deinit(allocator);
        const other = try Self.init(allocator, self.framebuffer_size[0], self.framebuffer_size[1], monitor_video_mode);
        self.window = other.window;
        self.gctx = other.gctx;
    }

    fn deinit(self: *Self, allocator: std.mem.Allocator) void {
        zgui.backend.deinit();
        zgui.plot.deinit();
        zgui.deinit();
        self.gctx.deinit(allocator);
        self.window.destroy();
    }
};

const XyData = std.DoublyLinkedList(struct {
    x: f64,
    y: f64,
});

const XyLine = struct {
    xv: []const f64,
    yv: []const f64,
    const Self = @This();

    fn init(allocator: std.mem.Allocator, xy_data: XyData) !Self {
        var xv = try allocator.alloc(f64, xy_data.len);
        var yv = try allocator.alloc(f64, xy_data.len);
        var current = xy_data.first;
        var i: usize = 0;
        while (current) |node| : ({
            current = node.next;
            i += 1;
        }) {
            xv[i] = node.data.x;
            yv[i] = node.data.y;
        }

        return .{
            .xv = xv,
            .yv = yv,
        };
    }

    fn deinit(self: Self, allocator: std.mem.Allocator) void {
        allocator.free(self.xv);
        allocator.free(self.yv);
    }
};

const MonitorVideoMode = struct {
    monitor: *zglfw.Monitor,
    video_mode: zglfw.VideoMode,
};

const DisplayWindow = struct {
    frame_time_history: XyData = .{},
    mode: Mode = .windowed,
    frame_target_option: FrameTargetOption = .frame_rate,
    frame_rate_target: i32 = 60,
    frame_time_target: f32 = 16.666,
    monitor_names: std.ArrayList([:0]const u8),
    monitor_video_modes: std.ArrayList(MonitorVideoMode),
    selected_monitor_video_mode: usize = 0,
    reinit_surface: bool = false,

    const Mode = enum {
        windowed,
        fullscreen,
    };

    const FrameTargetOption = enum {
        unlimited,
        frame_rate,
        frame_time,
    };

    pub fn init(allocator: std.mem.Allocator) !DisplayWindow {
        var monitor_names = std.ArrayList([:0]const u8).init(allocator);
        var monitor_video_modes = std.ArrayList(MonitorVideoMode).init(allocator);

        if (zglfw.Monitor.getAll()) |monitors| {
            for (monitors) |monitor| {
                for (try monitor.getVideoModes()) |video_mode| {
                    const bits = video_mode.red_bits + video_mode.green_bits + video_mode.blue_bits;
                    try monitor_names.append(try std.fmt.allocPrintZ(allocator, "{s} {}×{} {}-bits {}hz", .{
                        try monitor.getName(),
                        video_mode.width,
                        video_mode.height,
                        bits,
                        video_mode.refresh_rate,
                    }));
                    try monitor_video_modes.append(.{
                        .monitor = monitor,
                        .video_mode = video_mode,
                    });
                }
            }
        }
        return .{
            .monitor_names = monitor_names,
            .monitor_video_modes = monitor_video_modes,
        };
    }

    pub fn deinit(self: *DisplayWindow, allocator: std.mem.Allocator) void {
        while (self.frame_time_history.pop()) |frame_time| {
            allocator.destroy(frame_time);
        }
        for (self.monitor_names.items) |monitor_name| {
            allocator.free(monitor_name);
        }
        self.monitor_names.deinit();
        self.monitor_video_modes.deinit();
    }

    fn getSelectedMonitorName(self: DisplayWindow) [*:0]const u8 {
        return self.monitor_names.items[self.selected_monitor_video_mode];
    }
    fn getSelectedMonitorVideoMode(self: DisplayWindow) MonitorVideoMode {
        return self.monitor_video_modes.items[self.selected_monitor_video_mode];
    }

    fn show(self: *DisplayWindow, allocator: std.mem.Allocator, surface: Surface) !void {
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .first_use_ever });
        zgui.setNextWindowSize(.{ .w = 600, .h = 500, .cond = .first_use_ever });

        defer zgui.end();
        if (zgui.begin("Display", .{ .flags = .{ .always_auto_resize = true } })) {
            {
                {
                    var frame_time_node = try allocator.create(XyData.Node);
                    frame_time_node.data.x = surface.gctx.stats.time;
                    frame_time_node.data.y = surface.gctx.stats.average_cpu_time;
                    self.frame_time_history.append(frame_time_node);
                    while (self.frame_time_history.len > 100) {
                        const node = self.frame_time_history.popFirst() orelse unreachable;
                        allocator.destroy(node);
                    }
                }

                zgui.text(
                    "{d:.3} ms/frame ({d:.1} fps)",
                    .{ surface.gctx.stats.average_cpu_time, surface.gctx.stats.fps },
                );
                if (zgui.plot.beginPlot("frame times", .{ .h = surface.scale_factor * 100 })) {
                    defer zgui.plot.endPlot();
                    zgui.plot.setupAxis(.x1, .{
                        .flags = .{
                            .no_tick_labels = true,
                            .auto_fit = true,
                        },
                    });
                    zgui.plot.setupAxisLimits(.y1, .{ .min = 0, .max = 50 });
                    zgui.plot.setupLegend(.{}, .{});
                    zgui.plot.setupFinish();

                    const frame_time_line = try XyLine.init(allocator, self.frame_time_history);
                    defer frame_time_line.deinit(allocator);
                    zgui.plot.plotLine("##frame times data", f64, .{
                        .xv = frame_time_line.xv,
                        .yv = frame_time_line.yv,
                    });
                }
            }
            {
                zgui.separatorText("Mode");
                if (zgui.radioButton("windowed vsync on", .{ .active = self.mode == .windowed })) {
                    self.mode = .windowed;
                    self.reinit_surface = true;
                }
                {
                    if (zgui.radioButton("fullscreen vsync off", .{ .active = self.mode == .fullscreen })) {
                        self.mode = .fullscreen;
                        self.reinit_surface = true;
                    }
                    zgui.sameLine(.{});
                    {
                        if (zgui.beginCombo("##monitor", .{ .preview_value = self.getSelectedMonitorName() })) {
                            defer zgui.endCombo();

                            for (self.monitor_names.items, 0..) |monitor_name, i| {
                                if (zgui.selectable(monitor_name, .{ .selected = i == self.selected_monitor_video_mode })) {
                                    self.selected_monitor_video_mode = i;
                                    self.mode = .fullscreen;
                                    self.reinit_surface = true;
                                }
                            }
                        }
                    }
                }
            }
            {
                zgui.separatorText("Limiter");
                if (zgui.radioButton("unlimited", .{ .active = self.frame_target_option == .unlimited })) {
                    self.frame_target_option = .unlimited;
                }
                {
                    if (zgui.radioButton("frame rate", .{ .active = self.frame_target_option == .frame_rate })) {
                        self.frame_target_option = .frame_rate;
                    }
                    zgui.sameLine(.{});
                    {
                        zgui.beginDisabled(.{ .disabled = self.frame_target_option != .frame_rate });
                        defer zgui.endDisabled();

                        _ = zgui.sliderInt("##frame rate", .{ .v = &self.frame_rate_target, .min = 0, .max = 1000 });
                    }
                }

                {
                    if (zgui.radioButton("frame time (ms)", .{ .active = self.frame_target_option == .frame_time })) {
                        self.frame_target_option = .frame_time;
                    }
                    zgui.sameLine(.{});
                    {
                        zgui.beginDisabled(.{ .disabled = self.frame_target_option != .frame_time });
                        defer zgui.endDisabled();

                        _ = zgui.sliderFloat("##frame time", .{ .v = &self.frame_time_target, .min = 0, .max = 100 });
                    }
                }
            }
        }
    }
};

fn readOnlyCheckbox(label: [:0]const u8, v: bool) void {
    zgui.beginDisabled(.{ .disabled = true });
    defer zgui.endDisabled();
    _ = zgui.checkbox(label, .{ .v = @constCast(&v) });
}

fn readOnlyScalar(label: [:0]const u8, comptime T: type, v: T) void {
    _ = zgui.inputScalar(label, T, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyScalarN(label: [:0]const u8, comptime T: type, v: T) void {
    _ = zgui.inputScalarN(label, T, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyText(label: [:0]const u8, v: []const u8) void {
    _ = zgui.inputText(label, .{ .buf = @constCast(v), .flags = .{ .read_only = true } });
}

fn readOnlyFloat(label: [:0]const u8, v: f32) void {
    _ = zgui.inputFloat(label, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyInt(label: [:0]const u8, v: i32) void {
    _ = zgui.inputInt(label, .{ .v = @constCast(&v), .step = 0, .flags = .{ .read_only = true } });
}

fn readOnlyFloat2(label: [:0]const u8, v: [2]f32) void {
    _ = zgui.inputFloat2(label, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyFloat3(label: [:0]const u8, v: [3]f32) void {
    _ = zgui.inputFloat3(label, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyMatrix34(label: ?[:0]const u8, v: OpenVR.Matrix34) void {
    if (label) |l| {
        zgui.text("{s}", .{l});

        zgui.pushStrId(l);
        defer zgui.popId();
        zgui.indent(.{ .indent_w = 30 });
        defer zgui.unindent(.{ .indent_w = 30 });

        readOnlyFloat4("m[0]", v.m[0]);
        readOnlyFloat4("m[1]", v.m[1]);
        readOnlyFloat4("m[2]", v.m[2]);
    } else {
        readOnlyFloat4("m[0]", v.m[0]);
        readOnlyFloat4("m[1]", v.m[1]);
        readOnlyFloat4("m[2]", v.m[2]);
    }
}

fn readOnlyMatrix44(label: ?[:0]const u8, v: OpenVR.Matrix44) void {
    if (label) |l| {
        zgui.text("{s}", .{l});

        zgui.pushStrId(l);
        defer zgui.popId();
        zgui.indent(.{ .indent_w = 30 });
        defer zgui.unindent(.{ .indent_w = 30 });

        readOnlyFloat4("m[0]", v.m[0]);
        readOnlyFloat4("m[1]", v.m[1]);
        readOnlyFloat4("m[2]", v.m[2]);
        readOnlyFloat4("m[3]", v.m[3]);
    } else {
        readOnlyFloat4("m[0]", v.m[0]);
        readOnlyFloat4("m[1]", v.m[1]);
        readOnlyFloat4("m[2]", v.m[2]);
        readOnlyFloat4("m[3]", v.m[3]);
    }
}

fn readOnlyFloat4(label: [:0]const u8, v: [4]f32) void {
    _ = zgui.inputFloat4(label, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyColor4(label: [:0]const u8, v: [4]f32) void {
    zgui.beginDisabled(.{ .disabled = true });
    defer zgui.endDisabled();
    _ = zgui.colorEdit4(label, .{ .col = @constCast(&v), .flags = .{ .float = true } });
}
const SystemWindow = struct {
    projection_matrix_eye: OpenVR.Eye = .left,
    projection_matrix_near: f32 = 0,
    projection_matrix_far: f32 = 0,

    projection_raw_eye: OpenVR.Eye = .left,

    compute_distortion_eye: OpenVR.Eye = .left,
    compute_distortion_u: f32 = 0,
    compute_distortion_v: f32 = 0,

    tracked_device_property_device_index_bool: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_bool: OpenVR.System.TrackedDeviceProperty.Bool = .will_drift_in_yaw,

    tracked_device_property_device_index_f32: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_f32: OpenVR.System.TrackedDeviceProperty.F32 = .device_battery_percentage,

    tracked_device_property_device_index_i32: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_i32: OpenVR.System.TrackedDeviceProperty.I32 = .device_class,

    tracked_device_property_device_index_u64: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_u64: OpenVR.System.TrackedDeviceProperty.U64 = .hardware_revision,

    tracked_device_property_device_index_matrix34: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_matrix34: OpenVR.System.TrackedDeviceProperty.Matrix34 = .status_display_transform,

    tracked_device_property_device_index_f32_array: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_f32_array: OpenVR.System.TrackedDeviceProperty.Array.F32 = .camera_distortion_coefficients,

    tracked_device_property_device_index_i32_array: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_i32_array: OpenVR.System.TrackedDeviceProperty.Array.I32 = .camera_distortion_function,

    tracked_device_property_device_index_vector4_array: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_vector4_array: OpenVR.System.TrackedDeviceProperty.Array.Vector4 = .camera_white_balance,

    tracked_device_property_device_index_matrix34_array: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_matrix34_array: OpenVR.System.TrackedDeviceProperty.Array.Matrix34 = .camera_to_head_transforms,

    tracked_device_property_device_index_string: OpenVR.TrackedDeviceIndex = 0,
    tracked_device_property_string: OpenVR.System.TrackedDeviceProperty.String = .tracking_system_name,

    fn show(self: *SystemWindow, system: OpenVR.System, allocator: std.mem.Allocator) !void {
        zgui.setNextWindowPos(.{ .x = 100, .y = 0, .cond = .first_use_ever });
        defer zgui.end();
        if (zgui.begin("System", .{ .flags = .{ .always_auto_resize = true } })) {
            try guiGetter("getRecommendedRenderTargetSize", OpenVR.System.getRecommendedRenderTargetSize, system, .{}, "[width, height]");
            try guiGetter("getProjectionMatrix", OpenVR.System.getProjectionMatrix, system, .{
                .eye = &self.projection_matrix_eye,
                .near = &self.projection_matrix_near,
                .far = &self.projection_matrix_far,
            }, null);
            try guiGetter("getProjectionRaw", OpenVR.System.getProjectionRaw, system, .{
                .eye = &self.projection_raw_eye,
            }, null);
            try guiGetter("computeDistortion", OpenVR.System.computeDistortion, system, .{
                .eye = &self.compute_distortion_eye,
                .u = &self.compute_distortion_u,
                .v = &self.compute_distortion_v,
            }, null);

            try guiGetter("getBoolTrackedDeviceProperty", OpenVR.System.getBoolTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_bool,
                .property = &self.tracked_device_property_bool,
            }, null);
            try guiGetter("getF32TrackedDeviceProperty", OpenVR.System.getF32TrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_f32,
                .property = &self.tracked_device_property_f32,
            }, null);
            try guiGetter("getI32TrackedDeviceProperty", OpenVR.System.getI32TrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_i32,
                .property = &self.tracked_device_property_i32,
            }, null);
            try guiGetter("getU64TrackedDeviceProperty", OpenVR.System.getU64TrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_u64,
                .property = &self.tracked_device_property_u64,
            }, null);
            try guiGetter("getMatrix34TrackedDeviceProperty", OpenVR.System.getMatrix34TrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_matrix34,
                .property = &self.tracked_device_property_matrix34,
            }, null);

            try guiAllocGetter(allocator, "allocF32ArrayTrackedDeviceProperty", OpenVR.System.allocF32ArrayTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_f32_array,
                .property = &self.tracked_device_property_f32_array,
            }, null);
            try guiAllocGetter(allocator, "allocI32ArrayTrackedDeviceProperty", OpenVR.System.allocI32ArrayTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_i32_array,
                .property = &self.tracked_device_property_i32_array,
            }, null);
            try guiAllocGetter(allocator, "allocVector4ArrayTrackedDeviceProperty", OpenVR.System.allocVector4ArrayTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_vector4_array,
                .property = &self.tracked_device_property_vector4_array,
            }, null);
            try guiAllocGetter(allocator, "allocMatrix34ArrayTrackedDeviceProperty", OpenVR.System.allocMatrix34ArrayTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_matrix34_array,
                .property = &self.tracked_device_property_matrix34_array,
            }, null);

            try guiAllocGetter(allocator, "allocStringTrackedDeviceProperty", OpenVR.System.allocStringTrackedDeviceProperty, system, .{
                .device_index = &self.tracked_device_property_device_index_string,
                .property = &self.tracked_device_property_string,
            }, null);

            try guiGetter("getRuntimeVersion", OpenVR.System.getRuntimeVersion, system, .{}, null);
        }
    }
};

const ChaperoneWindow = struct {
    scene_color: OpenVR.Color = .{ .r = 0, .b = 0, .g = 0, .a = 1 },
    bound_colors_count: usize = 1,
    collision_bounds_fade_distance: f32 = 0,
    force_bounds_visible: bool = false,
    reset_zero_pose_origin: OpenVR.TrackingUniverseOrigin = .seated,

    fn show(
        self: *ChaperoneWindow,
        chaperone: OpenVR.Chaperone,
        allocator: std.mem.Allocator,
    ) !void {
        zgui.setNextWindowPos(.{ .x = 100, .y = 0, .cond = .first_use_ever });
        defer zgui.end();
        if (zgui.begin("Chaperone", .{ .flags = .{ .always_auto_resize = true } })) {
            try guiGetter("getCalibrationState", OpenVR.Chaperone.getCalibrationState, chaperone, .{}, null);
            try guiGetter("getPlayAreaSize", OpenVR.Chaperone.getPlayAreaSize, chaperone, .{}, "{x: meters, z: meters}");
            try guiGetter("getPlayAreaRect", OpenVR.Chaperone.getPlayAreaRect, chaperone, .{}, "{corners: [4][x meters, y meters, z meters]}");

            try guiSetter("reloadInfo", OpenVR.Chaperone.reloadInfo, chaperone, .{}, null);
            try guiSetter("setSceneColor", OpenVR.Chaperone.setSceneColor, chaperone, .{ .scene_color = &self.scene_color }, null);
            try guiAllocGetter(allocator, "allocBoundsColor", OpenVR.Chaperone.allocBoundsColor, chaperone, .{
                .collision_bounds_fade_distance = &self.collision_bounds_fade_distance,
                .bound_colors_count = &self.bound_colors_count,
            }, null);
            try guiGetter("areBoundsVisible", OpenVR.Chaperone.areBoundsVisible, chaperone, .{}, null);
            try guiSetter("forceBoundsVisible", OpenVR.Chaperone.forceBoundsVisible, chaperone, .{ .force = &self.force_bounds_visible }, null);
            try guiSetter("resetZeroPose", OpenVR.Chaperone.resetZeroPose, chaperone, .{ .origin = &self.reset_zero_pose_origin }, null);
        }
    }
};

fn readOnlyTrackedDevicePoses(label: [:0]const u8, poses: []OpenVR.TrackedDevicePose) void {
    if (poses.len > 0) {
        for (poses, 0..) |pose, i| {
            zgui.pushIntId(@intCast(i));
            defer zgui.popId();
            readOnlyTrackedDevicePose("{s}[{}]", .{ label, i }, pose);
        }
    } else {
        readOnlyText(label, "(empty)");
    }
}

fn readOnlyTrackedDevicePose(comptime fmt: []const u8, args: anytype, pose: OpenVR.TrackedDevicePose) void {
    zgui.text(fmt, args);
    zgui.indent(.{ .indent_w = 30 });
    defer zgui.unindent(.{ .indent_w = 30 });
    if (pose.pose_is_valid) {
        readOnlyMatrix34("device_to_absolute_tracking", pose.device_to_absolute_tracking);
        readOnlyFloat3("velocity.v: (meters/second)", pose.velocity.v);
        readOnlyFloat3("angular_velocity.v: (radians/second)", pose.angular_velocity.v);
        readOnlyText("tracking_result", @tagName(pose.tracking_result));
        readOnlyCheckbox("pose_is_valid", pose.pose_is_valid);
        readOnlyCheckbox("device_is_connected", pose.device_is_connected);
    } else {
        readOnlyCheckbox("pose_is_valid", false);
    }
}

fn readOnlyFrameTiming(frame_timing: OpenVR.Compositor.FrameTiming) void {
    readOnlyScalar("size", u32, frame_timing.size);
    readOnlyScalar("frame_index", u32, frame_timing.frame_index);
    readOnlyScalar("num_frame_presents", u32, frame_timing.num_frame_presents);
    readOnlyScalar("num_mis_presented", u32, frame_timing.num_mis_presented);
    readOnlyScalar("reprojection_flags", u32, frame_timing.reprojection_flags);
    readOnlyScalar("system_time_in_seconds", f64, frame_timing.system_time_in_seconds);
    readOnlyFloat("pre_submit_gpu_ms", frame_timing.pre_submit_gpu_ms);
    readOnlyFloat("post_submit_gpu_ms", frame_timing.post_submit_gpu_ms);
    readOnlyFloat("total_render_gpu_ms", frame_timing.total_render_gpu_ms);
    readOnlyFloat("compositor_render_gpu_ms", frame_timing.compositor_render_gpu_ms);
    readOnlyFloat("compositor_render_cpu_ms", frame_timing.compositor_render_cpu_ms);
    readOnlyFloat("compositor_idle_cpu_ms", frame_timing.compositor_idle_cpu_ms);
    readOnlyFloat("client_frame_interval_ms", frame_timing.client_frame_interval_ms);
    readOnlyFloat("present_call_cpu_ms", frame_timing.present_call_cpu_ms);
    readOnlyFloat("wait_for_present_cpu_ms", frame_timing.wait_for_present_cpu_ms);
    readOnlyFloat("submit_frame_ms", frame_timing.submit_frame_ms);
    readOnlyFloat("wait_get_poses_called_ms", frame_timing.wait_get_poses_called_ms);
    readOnlyFloat("new_poses_ready_ms", frame_timing.new_poses_ready_ms);
    readOnlyFloat("new_frame_ready_ms", frame_timing.new_frame_ready_ms);
    readOnlyFloat("compositor_update_start_ms", frame_timing.compositor_update_start_ms);
    readOnlyFloat("compositor_update_end_ms", frame_timing.compositor_update_end_ms);
    readOnlyFloat("compositor_render_start_ms", frame_timing.compositor_render_start_ms);
    readOnlyFloat("compositor_render_start_ms", frame_timing.compositor_render_start_ms);
    readOnlyTrackedDevicePose("pose", .{}, frame_timing.pose);
    readOnlyScalar("num_v_syncs_ready_for_use", u32, frame_timing.num_v_syncs_ready_for_use);
    readOnlyScalar("num_v_syncs_to_first_view", u32, frame_timing.num_v_syncs_to_first_view);
}

const CompositorWindow = struct {
    wait_render_poses_count: usize = 1,
    wait_game_poses_count: usize = 1,
    last_render_poses_count: usize = 1,
    last_game_poses_count: usize = 1,
    last_pose_device_index: u32 = 0,
    frame_timing_frames_ago: u32 = 0,
    frame_timing_frames: u32 = 1,
    fade_color_seconds: f32 = 0,
    fade_color_background: bool = false,
    fade_color: OpenVR.Color = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
    current_fade_color_background: bool = false,
    fade_grid_seconds: f32 = 0,
    fade_grid_background: bool = false,
    tracking_space_origin: OpenVR.TrackingUniverseOrigin = .seated,
    force_interleaved_reprojection_override_on: bool = false,
    suspend_rendering: bool = false,

    fn show(self: *CompositorWindow, compositor: OpenVR.Compositor, allocator: std.mem.Allocator) !void {
        zgui.setNextWindowPos(.{ .x = 100, .y = 0, .cond = .first_use_ever });
        defer zgui.end();
        if (zgui.begin("Compositor", .{ .flags = .{ .always_auto_resize = true } })) {
            try guiGetter("getTrackingSpace", OpenVR.Compositor.getTrackingSpace, compositor, .{}, null);
            try guiSetter("setTrackingSpace", OpenVR.Compositor.setTrackingSpace, compositor, .{ .origin = &self.tracking_space_origin }, null);
            guiAllocGetter(allocator, "allocWaitPoses", OpenVR.Compositor.allocWaitPoses, compositor, .{
                .render_poses_count = &self.wait_render_poses_count,
                .game_poses_count = &self.wait_game_poses_count,
            }, null) catch |err| switch (err) {
                error.DoNotHaveFocus => {
                    zgui.text("{!}", .{err});
                },
                else => return err,
            };
            try guiAllocGetter(allocator, "allocLastPoses", OpenVR.Compositor.allocLastPoses, compositor, .{
                .render_poses_count = &self.last_render_poses_count,
                .game_poses_count = &self.last_game_poses_count,
            }, null);
            try guiGetter("getLastPoseForTrackedDeviceIndex", OpenVR.Compositor.getLastPoseForTrackedDeviceIndex, compositor, .{
                .device_index = &self.last_pose_device_index,
            }, null);
            {
                zgui.separatorText("Submit");
            }
            try guiGetter("getFrameTiming", OpenVR.Compositor.getFrameTiming, compositor, .{
                .frames_ago = &self.frame_timing_frames_ago,
            }, "?FrameTiming");
            {
                zgui.separatorText("Frame timing");
                {
                    zgui.text("Frames", .{});
                    zgui.pushStrId("allocFrameTimings");
                    defer zgui.popId();

                    _ = zgui.inputScalar("frames", u32, .{
                        .v = &self.frame_timing_frames,
                        .step = 1,
                    });
                    if (self.frame_timing_frames < 1) {
                        self.frame_timing_frames = 1;
                    }
                    const frames = try compositor.allocFrameTimings(allocator, self.frame_timing_frames);
                    defer allocator.free(frames);
                    for (frames, 0..) |frame_timing, i| {
                        zgui.pushIntId(@intCast(i));
                        defer zgui.popId();
                        readOnlyFrameTiming(frame_timing);
                    }
                }
            }
            try guiGetter("getFrameTimeRemaining", OpenVR.Compositor.getFrameTimeRemaining, compositor, .{}, null);
            try guiGetter("getCumulativeStats", OpenVR.Compositor.getCumulativeStats, compositor, .{}, null);
            try guiGetter("getCurrentFadeColor", OpenVR.Compositor.getCurrentFadeColor, compositor, .{ .background = &self.current_fade_color_background }, null);
            try guiSetter("fadeToColor", OpenVR.Compositor.fadeToColor, compositor, .{
                .seconds = &self.fade_color_seconds,
                .color = &self.fade_color,
                .background = &self.fade_color_background,
            }, null);
            try guiGetter("getCurrentGridAlpha", OpenVR.Compositor.getCurrentGridAlpha, compositor, .{}, null);
            try guiSetter("fadeGrid", OpenVR.Compositor.fadeGrid, compositor, .{
                .seconds = &self.fade_grid_seconds,
                .background = &self.fade_grid_background,
            }, null);

            try guiSetter("compositorBringToFront", OpenVR.Compositor.compositorBringToFront, compositor, .{}, null);
            try guiSetter("compositorGoToBack", OpenVR.Compositor.compositorGoToBack, compositor, .{}, null);
            try guiSetter("compositorQuit", OpenVR.Compositor.compositorQuit, compositor, .{}, null);

            try guiGetter("isFullscreen", OpenVR.Compositor.isFullscreen, compositor, .{}, null);
            try guiGetter("getCurrentSceneFocusProcess", OpenVR.Compositor.getCurrentSceneFocusProcess, compositor, .{}, null);
            try guiGetter("getLastFrameRenderer", OpenVR.Compositor.getLastFrameRenderer, compositor, .{}, null);
            try guiGetter("canRenderScene", OpenVR.Compositor.canRenderScene, compositor, .{}, null);

            try guiSetter("compositorDumpImages", OpenVR.Compositor.compositorDumpImages, compositor, .{}, null);

            try guiGetter("shouldAppRenderWithLowResources", OpenVR.Compositor.shouldAppRenderWithLowResources, compositor, .{}, null);

            try guiSetter("forceInterleavedReprojectionOn", OpenVR.Compositor.forceInterleavedReprojectionOn, compositor, .{ .override = &self.force_interleaved_reprojection_override_on }, null);
            try guiSetter("forceReconnectProcess", OpenVR.Compositor.forceReconnectProcess, compositor, .{}, null);
            try guiSetter("suspendRendering", OpenVR.Compositor.suspendRendering, compositor, .{ .suspend_rendering = &self.suspend_rendering }, null);

            try guiGetter("isMotionSmoothingEnabled", OpenVR.Compositor.isMotionSmoothingEnabled, compositor, .{}, null);
            try guiGetter("isMotionSmoothingSupported", OpenVR.Compositor.isMotionSmoothingSupported, compositor, .{}, null);
        }
    }
};

fn guiParams(comptime arg_types: []type, comptime arg_ptrs_info: std.builtin.Type.Struct, arg_ptrs: anytype) void {
    if (arg_types.len > 0) {
        zgui.indent(.{ .indent_w = 30 });
        defer zgui.unindent(.{ .indent_w = 30 });
        if (arg_types.len != arg_ptrs_info.fields.len) {
            @compileError(std.fmt.comptimePrint("expected arg_ptrs to have {} fields, but was {}", .{ arg_types.len, arg_ptrs_info.fields.len }));
        }
        inline for (arg_types, 0..) |arg_type, i| {
            const arg_name: [:0]const u8 = std.fmt.comptimePrint("{s}", .{arg_ptrs_info.fields[i].name});
            const arg_ptr = @field(arg_ptrs, arg_name);
            switch (arg_type) {
                bool => {
                    _ = zgui.checkbox(arg_name, .{ .v = arg_ptr });
                },
                u32 => {
                    _ = zgui.inputScalar(arg_name, u32, .{
                        .v = arg_ptr,
                        .step = 1,
                    });
                },
                usize => {
                    _ = zgui.inputScalar(arg_name, usize, .{
                        .v = arg_ptr,
                        .step = 1,
                    });
                },
                f32 => {
                    _ = zgui.inputFloat(arg_name, .{ .v = arg_ptr });
                },
                OpenVR.Color => {
                    _ = zgui.colorEdit4(arg_name, .{ .col = @ptrCast(arg_ptr), .flags = .{ .float = true } });
                },
                OpenVR.TrackingUniverseOrigin,
                OpenVR.Eye,
                OpenVR.System.TrackedDeviceProperty.Bool,
                OpenVR.System.TrackedDeviceProperty.F32,
                OpenVR.System.TrackedDeviceProperty.I32,
                OpenVR.System.TrackedDeviceProperty.U64,
                OpenVR.System.TrackedDeviceProperty.Matrix34,
                OpenVR.System.TrackedDeviceProperty.Array.F32,
                OpenVR.System.TrackedDeviceProperty.Array.I32,
                OpenVR.System.TrackedDeviceProperty.Array.Vector4,
                OpenVR.System.TrackedDeviceProperty.Array.Matrix34,
                OpenVR.System.TrackedDeviceProperty.String,
                => {
                    _ = zgui.comboFromEnum(arg_name, arg_ptr);
                },
                else => @compileError(@typeName(arg_type) ++ " not implemented"),
            }
            zgui.sameLine(.{});
            zgui.text(", ", .{});
        }
    } else {
        zgui.sameLine(.{});
    }
}

fn guiResult(comptime Return: type, result: Return) void {
    zgui.indent(.{ .indent_w = 30 });
    defer zgui.unindent(.{ .indent_w = 30 });
    switch (Return) {
        bool => readOnlyCheckbox("##", result),
        i32 => readOnlyInt("##", result),
        []i32 => if (result.len > 0) {
            for (result, 0..) |v, i| {
                zgui.pushIntId(@intCast(i));
                defer zgui.popId();
                readOnlyInt("##", v);
                zgui.sameLine(.{});
                zgui.text("[{}]", .{i});
            }
        } else {
            zgui.text("(empty)", .{});
        },
        u32 => readOnlyScalar("##", u32, result),
        u64 => readOnlyScalar("##", u64, result),
        f32 => readOnlyFloat("##", result),
        []f32 => if (result.len > 0) {
            for (result, 0..) |v, i| {
                zgui.pushIntId(@intCast(i));
                defer zgui.popId();
                readOnlyFloat("##", v);
                zgui.sameLine(.{});
                zgui.text("[{}]", .{i});
            }
        } else {
            zgui.text("(empty)", .{});
        },
        OpenVR.System.RenderTargetSize => readOnlyScalarN("##", [2]u32, .{
            @as(OpenVR.System.RenderTargetSize, result).width,
            @as(OpenVR.System.RenderTargetSize, result).height,
        }),
        ?OpenVR.Compositor.FrameTiming => {
            if (result) |frame_timing| {
                readOnlyFrameTiming(frame_timing);
            } else {
                zgui.text("null", .{});
            }
        },
        [:0]const u8 => readOnlyText("##", result),
        OpenVR.Chaperone.CalibrationState, OpenVR.TrackingUniverseOrigin => readOnlyText("##", @tagName(result)),
        ?OpenVR.Chaperone.PlayAreaSize => {
            if (result) |play_area_size| {
                readOnlyFloat("x", play_area_size.x);
                readOnlyFloat("z", play_area_size.z);
            } else {
                zgui.text("null", .{});
            }
        },
        ?OpenVR.Quad => {
            if (result) |quad| {
                readOnlyFloat3("corners[0]", quad.corners[0].v);
                readOnlyFloat3("corners[1]", quad.corners[1].v);
                readOnlyFloat3("corners[2]", quad.corners[2].v);
                readOnlyFloat3("corners[3]", quad.corners[3].v);
            } else {
                zgui.text("null", .{});
            }
        },
        OpenVR.Compositor.CumulativeStats => {
            readOnlyScalar("pid", u32, result.pid);
            readOnlyScalar("num_frame_presents", u32, result.num_frame_presents);
            readOnlyScalar("num_dropped_frames", u32, result.num_dropped_frames);
            readOnlyScalar("num_reprojected_frames", u32, result.num_reprojected_frames);
            readOnlyScalar("num_frame_presents_on_startup", u32, result.num_frame_presents_on_startup);
            readOnlyScalar("num_dropped_frames_on_startup", u32, result.num_dropped_frames_on_startup);
            readOnlyScalar("num_reprojected_frames_on_startup", u32, result.num_reprojected_frames_on_startup);
            readOnlyScalar("num_loading", u32, result.num_loading);
            readOnlyScalar("num_frame_presents_loading", u32, result.num_frame_presents_loading);
            readOnlyScalar("num_dropped_frames_loading", u32, result.num_dropped_frames_loading);
            readOnlyScalar("num_reprojected_frames_loading", u32, result.num_reprojected_frames_loading);
            readOnlyScalar("num_timed_out", u32, result.num_timed_out);
            readOnlyScalar("num_frame_presents_timed_out", u32, result.num_frame_presents_timed_out);
            readOnlyScalar("num_dropped_frames_timed_out", u32, result.num_dropped_frames_timed_out);
            readOnlyScalar("num_reprojected_frames_timed_out", u32, result.num_reprojected_frames_timed_out);
            readOnlyScalar("num_frame_submits", u32, result.num_frame_submits);
            readOnlyScalar("sum_compositor_cpu_time_ms", f64, result.sum_compositor_cpu_time_ms);
            readOnlyScalar("sum_compositor_gpu_time_ms", f64, result.sum_compositor_gpu_time_ms);
            readOnlyScalar("sum_target_frame_times", f64, result.sum_target_frame_times);
            readOnlyScalar("sum_application_cpu_time_ms", f64, result.sum_application_cpu_time_ms);
            readOnlyScalar("sum_application_gpu_time_ms", f64, result.sum_application_gpu_time_ms);
            readOnlyScalar("num_frames_with_depth", u32, result.num_frames_with_depth);
        },
        OpenVR.Compositor.Pose => {
            readOnlyTrackedDevicePose("render_pose", .{}, result.render_pose);
            readOnlyTrackedDevicePose("game_pose", .{}, result.game_pose);
        },
        OpenVR.Compositor.Poses => {
            readOnlyTrackedDevicePoses("render_poses", result.render_poses);
            readOnlyTrackedDevicePoses("game_poses", result.game_poses);
        },
        OpenVR.Color => readOnlyColor4("##", @bitCast(result)),
        OpenVR.Chaperone.BoundsColor => {
            if (result.bound_colors.len > 0) {
                for (result.bound_colors, 0..) |bound_color, i| {
                    zgui.pushIntId(@intCast(i));
                    defer zgui.popId();
                    readOnlyColor4("bound_colors", @bitCast(bound_color));
                    zgui.sameLine(.{});
                    zgui.text("[{}]", .{i});
                }
            } else {
                readOnlyText("bound_colors", "(empty)");
            }
            readOnlyColor4("camera_color", @bitCast(result.camera_color));
        },
        []OpenVR.Vector4 => if (result.len > 0) {
            for (result, 0..) |v, i| {
                zgui.pushIntId(@intCast(i));
                defer zgui.popId();
                readOnlyFloat4("##", v.v);
                zgui.sameLine(.{});
                zgui.text("[{}]", .{i});
            }
        } else {
            zgui.text("(empty)", .{});
        },
        OpenVR.Matrix34 => readOnlyMatrix34(null, result),
        OpenVR.Matrix44 => readOnlyMatrix44(null, result),
        OpenVR.System.RawProjection => {
            readOnlyFloat("left", result.left);
            readOnlyFloat("right", result.right);
            readOnlyFloat("top", result.top);
            readOnlyFloat("bottom", result.bottom);
        },
        ?OpenVR.System.DistortionCoordinates => {
            if (result) |distortion_coordinates| {
                readOnlyFloat2("red", distortion_coordinates.red);
                readOnlyFloat2("green", distortion_coordinates.green);
                readOnlyFloat2("blue", distortion_coordinates.blue);
            } else {
                zgui.text("null", .{});
            }
        },
        []OpenVR.Matrix34 => if (result.len > 0) {
            for (result, 0..) |v, i| {
                zgui.pushIntId(@intCast(i));
                defer zgui.popId();
                readOnlyMatrix34(null, v);
                zgui.sameLine(.{});
                zgui.text("[{}]", .{i});
            }
        } else {
            zgui.text("(empty)", .{});
        },
        OpenVR.Vector4 => readOnlyFloat4("##", result.v),
        [:0]u8 => zgui.text("{s}", .{result}),
        else => @compileError(@typeName(Return) ++ " not implemented"),
    }
}

fn guiGetter(comptime f_name: [:0]const u8, comptime f: anytype, self: anytype, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const F = @TypeOf(f);
    const f_info = @typeInfo(F).Fn;
    comptime var arg_types: [f_info.params.len]type = undefined;
    inline for (f_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const ArgPtrs = @TypeOf(arg_ptrs);
    const arg_ptrs_info = @typeInfo(ArgPtrs).Struct;

    const Args = std.meta.Tuple(&arg_types);
    var args: Args = undefined;
    {
        args[0] = self;

        if (arg_types.len > 1) {
            inline for (arg_ptrs_info.fields, 0..) |field, i| {
                const arg_ptr = @field(arg_ptrs, field.name);
                args[i + 1] = arg_ptr.*;
            }
        }
    }

    const Return = f_info.return_type.?;
    const return_type_info = @typeInfo(Return);
    const Payload = switch (return_type_info) {
        .ErrorUnion => |error_union| error_union.payload,
        else => Return,
    };
    const payload_prefix = switch (return_type_info) {
        .ErrorUnion => "!",
        else => "",
    };

    {
        zgui.text("{s}(", .{f_name});
        guiParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
        zgui.text(") {s}", .{return_doc orelse (payload_prefix ++ @typeName(Payload))});
    }

    const result: Payload = switch (return_type_info) {
        .ErrorUnion => |error_union| switch (error_union.error_set) {
            OpenVR.System.TrackedPropertyError => @call(.auto, f, args) catch |err| switch (err) {
                OpenVR.System.TrackedPropertyError.UnknownProperty,
                OpenVR.System.TrackedPropertyError.NotYetAvailable,
                OpenVR.System.TrackedPropertyError.InvalidDevice,
                => {
                    zgui.indent(.{ .indent_w = 30 });
                    defer zgui.unindent(.{ .indent_w = 30 });
                    zgui.text("{!}", .{err});
                    zgui.newLine();
                    return;
                },
                else => return err,
            },
            else => try @call(.auto, f, args),
        },
        else => @call(.auto, f, args),
    };

    guiResult(Payload, result);
    zgui.newLine();
}

fn guiAllocGetter(allocator: std.mem.Allocator, comptime f_name: [:0]const u8, comptime f: anytype, self: anytype, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const F = @TypeOf(f);
    const f_info = @typeInfo(F).Fn;
    comptime var arg_types: [f_info.params.len]type = undefined;
    inline for (f_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }

    const ArgPtrs = @TypeOf(arg_ptrs);
    const arg_ptrs_info = @typeInfo(ArgPtrs).Struct;

    const Args = std.meta.Tuple(&arg_types);
    var args: Args = undefined;
    {
        args[0] = self;
        args[1] = allocator;

        if (arg_types.len > 2) {
            inline for (arg_ptrs_info.fields, 0..) |field, i| {
                const arg_ptr = @field(arg_ptrs, field.name);
                args[i + 2] = arg_ptr.*;
            }
        }
    }

    const Return = f_info.return_type.?;
    const return_type_info = @typeInfo(Return);
    const Payload = return_type_info.ErrorUnion.payload;

    {
        zgui.text("{s}(", .{f_name});
        {
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });
            zgui.text("allocator", .{});
            zgui.sameLine(.{});
            zgui.text(",", .{});
        }
        guiParams(arg_types[2..], arg_ptrs_info, arg_ptrs);
        zgui.text(") {s}", .{return_doc orelse ("!" ++ @typeName(Payload))});
    }

    const result: Payload = switch (return_type_info.ErrorUnion.error_set) {
        OpenVR.System.TrackedPropertyError => @call(.auto, f, args) catch |err| switch (err) {
            OpenVR.System.TrackedPropertyError.UnknownProperty,
            OpenVR.System.TrackedPropertyError.NotYetAvailable,
            OpenVR.System.TrackedPropertyError.InvalidDevice,
            => {
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });
                zgui.text("{!}", .{err});
                zgui.newLine();
                return;
            },
            else => return err,
        },
        else => try @call(.auto, f, args),
    };

    defer switch (Payload) {
        OpenVR.Chaperone.BoundsColor,
        OpenVR.Compositor.Poses,
        => result.deinit(allocator),
        [:0]u8,
        []f32,
        []i32,
        []OpenVR.Vector4,
        []OpenVR.Matrix34,
        => allocator.free(result),
        else => @compileError(@typeName(Payload) ++ " not implemented"),
    };

    guiResult(Payload, result);
    zgui.newLine();
}

fn guiSetter(comptime f_name: [:0]const u8, comptime f: anytype, self: anytype, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const F = @TypeOf(f);
    const f_info = @typeInfo(F).Fn;
    comptime var arg_types: [f_info.params.len]type = undefined;
    inline for (f_info.params, 0..) |param, i| {
        arg_types[i] = param.type.?;
    }
    const ArgPtrs = @TypeOf(arg_ptrs);
    const arg_ptrs_info = @typeInfo(ArgPtrs).Struct;

    const Args = std.meta.Tuple(&arg_types);
    var args: Args = undefined;
    {
        args[0] = self;

        if (arg_types.len > 1) {
            inline for (arg_ptrs_info.fields, 0..) |field, i| {
                const arg_ptr = @field(arg_ptrs, field.name);
                args[i + 1] = arg_ptr.*;
            }
        }
    }

    const Return = f_info.return_type.?;
    const return_type_info = @typeInfo(Return);
    const Payload = switch (return_type_info) {
        .ErrorUnion => |error_union| error_union.payload,
        else => Return,
    };
    if (@typeInfo(Payload) != .Void) {
        @compileError(@typeInfo(Payload) ++ " must be void");
    }
    const payload_prefix = switch (return_type_info) {
        .ErrorUnion => "!",
        else => "",
    };

    if (zgui.button(f_name, .{})) {
        switch (return_type_info) {
            .ErrorUnion => try @call(.auto, f, args),
            else => @call(.auto, f, args),
        }
    }
    zgui.sameLine(.{});
    zgui.text("(", .{});
    guiParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
    zgui.text(") {s}", .{return_doc orelse (payload_prefix ++ @typeName(Payload))});

    zgui.newLine();
}

const Windows = enum {
    system,
    chaperone,
    compositor,
};

const OpenVRWindow = struct {
    init_error: OpenVR.InitError = OpenVR.InitError.None,
    openvr: ?OpenVR = null,

    system_init_error: OpenVR.InitError = OpenVR.InitError.None,
    system: ?OpenVR.System = null,
    system_window: SystemWindow = .{},

    chaperone_init_error: OpenVR.InitError = OpenVR.InitError.None,
    chaperone: ?OpenVR.Chaperone = null,
    chaperone_window: ChaperoneWindow = .{},

    compositor_init_error: OpenVR.InitError = OpenVR.InitError.None,
    compositor: ?OpenVR.Compositor = null,
    compositor_window: CompositorWindow = .{},

    next_window_focus: ?Windows = null,

    pub fn init() OpenVRWindow {
        return .{};
    }

    pub fn deinit(self: *OpenVRWindow) void {
        if (self.openvr) |openvr| {
            openvr.deinit();
        }
        self.openvr = null;
        self.system = null;
        self.chaperone = null;
        self.compositor = null;
    }

    fn show(self: *OpenVRWindow, allocator: std.mem.Allocator) !void {
        zgui.setNextWindowPos(.{ .x = 0, .y = 0, .cond = .first_use_ever });

        defer zgui.end();
        if (zgui.begin("OpenVR", .{ .flags = .{ .always_auto_resize = true } })) {
            if (self.openvr) |openvr| {
                if (zgui.button("deinit()", .{})) {
                    openvr.deinit();
                    self.openvr = null;
                    self.system = null;
                    self.chaperone = null;
                    self.compositor = null;
                    return;
                }

                try guiGetter("isHmdPresent", OpenVR.isHmdPresent, openvr, .{}, null);
                try guiGetter("isRuntimeInstalled", OpenVR.isRuntimeInstalled, openvr, .{}, null);

                if (self.system == null) {
                    self.system_init_error = OpenVR.InitError.None;
                    self.system = openvr.system() catch |err| system: {
                        self.system_init_error = err;
                        break :system null;
                    };

                    if (self.system_init_error != OpenVR.InitError.None) {
                        zgui.text("system() error: {!}", .{self.system_init_error});
                    }
                } else {
                    if (zgui.button("focus system window", .{})) {
                        self.next_window_focus = .system;
                    }
                }
                zgui.newLine();

                if (self.system != null) {
                    if (self.chaperone == null) {
                        self.chaperone_init_error = OpenVR.InitError.None;
                        self.chaperone = openvr.chaperone() catch |err| chaperone: {
                            self.chaperone_init_error = err;
                            break :chaperone null;
                        };
                        if (self.chaperone_init_error != OpenVR.InitError.None) {
                            zgui.text("chaperone() error: {!}", .{self.chaperone_init_error});
                        }
                    } else {
                        if (zgui.button("focus chaperone window", .{})) {
                            self.next_window_focus = .chaperone;
                        }
                    }
                }
                zgui.newLine();

                if (self.system != null and self.chaperone != null) {
                    if (self.compositor == null) {
                        self.compositor_init_error = OpenVR.InitError.None;
                        self.compositor = openvr.compositor() catch |err| compositor: {
                            self.compositor_init_error = err;
                            break :compositor null;
                        };
                        if (self.compositor_init_error != OpenVR.InitError.None) {
                            zgui.text("compositor() error: {!}", .{self.compositor_init_error});
                        }
                    } else {
                        if (zgui.button("focus compositor window", .{})) {
                            self.next_window_focus = .compositor;
                        }
                    }
                }
            } else {
                if (zgui.button("OpenVR.init()", .{})) {
                    self.init_error = OpenVR.InitError.None;
                    self.openvr = OpenVR.init(.scene) catch |err| openvr: {
                        self.init_error = err;
                        break :openvr null;
                    };
                }
                if (self.init_error != OpenVR.InitError.None) {
                    zgui.text("OpenVR.init() error: {!}", .{self.init_error});
                }
            }
        }
        if (self.system) |system| {
            if (self.next_window_focus == .system) {
                zgui.setNextWindowFocus();
                self.next_window_focus = null;
            }
            try self.system_window.show(system, allocator);
        }
        if (self.chaperone) |chaperone| {
            if (self.next_window_focus == .chaperone) {
                zgui.setNextWindowFocus();
                self.next_window_focus = null;
            }
            try self.chaperone_window.show(chaperone, allocator);
        }
        if (self.compositor) |compositor| {
            if (self.next_window_focus == .compositor) {
                zgui.setNextWindowFocus();
                self.next_window_focus = null;
            }
            try self.compositor_window.show(compositor, allocator);
        }
    }
};

pub fn main() !void {
    // Change current working directory to where the executable is located.
    {
        var buffer: [1024]u8 = undefined;
        const path = std.fs.selfExeDirPath(buffer[0..]) catch ".";
        try std.os.chdir(path);
    }

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    try zglfw.init();
    defer zglfw.terminate();

    var surface = try Surface.init(allocator, 1280, 720, null);
    defer surface.deinit(allocator);

    var display_window = try DisplayWindow.init(allocator);
    defer display_window.deinit(allocator);

    var open_vr_window = OpenVRWindow.init();
    defer open_vr_window.deinit();

    var frame_timer = try std.time.Timer.start();

    main: while (!surface.window.shouldClose() and surface.window.getKey(.escape) != .press) {
        if (display_window.reinit_surface) {
            switch (display_window.mode) {
                .windowed => try surface.reinit(allocator, null),
                .fullscreen => {
                    try surface.reinit(allocator, display_window.getSelectedMonitorVideoMode());
                },
            }
            display_window.reinit_surface = false;
            continue :main;
        }

        {
            const next_framebuffer_size = surface.window.getFramebufferSize();
            if (!std.meta.eql(surface.framebuffer_size, next_framebuffer_size)) {
                display_window.reinit_surface = true;
            }
            surface.framebuffer_size = next_framebuffer_size;
            //std.mem.copyForwards(&next_framebuffer_size, &surface.framebuffer_size);
            if (display_window.reinit_surface) {
                continue :main;
            }
        }

        {
            // spin loop for frame limiter
            const ns_in_ms = 1_000_000;
            const ns_in_s = 1_000_000_000;
            var target_ns: ?u64 = null;
            if (display_window.frame_target_option == .frame_rate) {
                target_ns = @divTrunc(ns_in_s, @as(u64, @intCast(display_window.frame_rate_target)));
            }
            if (display_window.frame_target_option == .frame_time) {
                target_ns = @as(u64, @intFromFloat(ns_in_ms * display_window.frame_time_target));
            }
            if (target_ns) |t| {
                while (frame_timer.read() < t) {
                    std.atomic.spinLoopHint();
                }
                frame_timer.reset();
            }
        }

        // poll for input immediately after vsync or frame limiter to reduce input latency
        zglfw.pollEvents();

        {
            surface.gctx.beginFrame();
            defer surface.gctx.endFrame();

            const back_buffer = surface.gctx.getBackBuffer();
            surface.gctx.addTransitionBarrier(back_buffer.resource_handle, .{ .RENDER_TARGET = true });
            surface.gctx.flushResourceBarriers();

            surface.gctx.cmdlist.OMSetRenderTargets(
                1,
                &[_]d3d12.CPU_DESCRIPTOR_HANDLE{back_buffer.descriptor_handle},
                w32.TRUE,
                null,
            );
            surface.gctx.cmdlist.ClearRenderTargetView(
                back_buffer.descriptor_handle,
                &.{ 0.0, 0.0, 0.0, 1.0 },
                0,
                null,
            );

            zgui.backend.newFrame(
                @intCast(surface.framebuffer_size[0]),
                @intCast(surface.framebuffer_size[1]),
            );

            // try display_window.show(allocator, surface);
            try open_vr_window.show(allocator);

            zgui.backend.draw(surface.gctx.cmdlist);

            surface.gctx.addTransitionBarrier(back_buffer.resource_handle, d3d12.RESOURCE_STATES.PRESENT);
            surface.gctx.flushResourceBarriers();
        }
    }

    surface.gctx.finishGpuCommands();
}
