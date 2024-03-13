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
        if (zgui.begin("Display", .{})) {
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

const OpenVRWindow = struct {
    init_error: OpenVR.InitError = OpenVR.InitError.None,
    openvr: ?OpenVR = null,

    system_init_error: OpenVR.InitError = OpenVR.InitError.None,
    system: ?OpenVR.System = null,

    chaperone_init_error: OpenVR.InitError = OpenVR.InitError.None,
    chaperone: ?OpenVR.Chaperone = null,

    compositor_init_error: OpenVR.InitError = OpenVR.InitError.None,
    compositor: ?OpenVR.Compositor = null,

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
        zgui.setNextWindowPos(.{ .x = 20.0, .y = 20.0, .cond = .first_use_ever });
        zgui.setNextWindowSize(.{ .w = 1000, .h = 1000, .cond = .first_use_ever });

        defer zgui.end();
        if (zgui.begin("OpenVR", .{})) {
            if (self.openvr) |openvr| {
                if (zgui.button("shutdown", .{})) {
                    openvr.deinit();
                    self.openvr = null;
                    self.system = null;
                    self.chaperone = null;
                    self.compositor = null;
                    return;
                }
                {
                    zgui.beginDisabled(.{ .disabled = true });
                    defer zgui.endDisabled();
                    _ = zgui.checkbox("head mounted display present", .{ .v = @constCast(&openvr.isHmdPresent()) });
                    _ = zgui.checkbox("runtime installed", .{ .v = @constCast(&openvr.isRuntimeInstalled()) });
                }

                zgui.separatorText("System");
                if (self.system) |system| {
                    zgui.beginDisabled(.{ .disabled = true });
                    defer zgui.endDisabled();

                    {
                        zgui.text("recommended render target size", .{});
                        zgui.indent(.{ .indent_w = 30.0 });
                        defer zgui.unindent(.{ .indent_w = 30.0 });
                        const recommended_render_target_size = system.getRecommendedRenderTargetSize();
                        _ = zgui.inputScalar("width", u32, .{ .v = @constCast(&recommended_render_target_size.width) });
                        _ = zgui.inputScalar("height", u32, .{ .v = @constCast(&recommended_render_target_size.height) });
                    }

                    _ = zgui.inputText("runtime version", .{ .buf = @constCast(system.getRuntimeVersion()) });
                    zgui.separatorText("head mounted display properties");
                    {
                        zgui.indent(.{ .indent_w = 30.0 });
                        defer zgui.unindent(.{ .indent_w = 30.0 });
                        inline for (@typeInfo(OpenVR.System.TrackedDeviceProperty.String).Enum.fields) |field| {
                            const value: ?[]u8 = system.allocStringTrackedDeviceProperty(allocator, 0, @as(OpenVR.System.TrackedDeviceProperty.String, @enumFromInt(field.value))) catch |err| switch (err) {
                                OpenVR.System.TrackedPropertyError.UnknownProperty => null,
                                OpenVR.System.TrackedPropertyError.NotYetAvailable => null,
                                else => return err,
                            };
                            defer if (value) |v| allocator.free(v);
                            _ = zgui.inputText(field.name ++ "##tracked device property string", .{ .buf = @constCast(value orelse "Unknown property/not yet available") });
                        }
                    }
                } else {
                    if (zgui.button("init", .{})) {
                        self.system_init_error = OpenVR.InitError.None;
                        self.system = openvr.system() catch |err| system: {
                            self.system_init_error = err;
                            break :system null;
                        };
                    }
                    zgui.text("init error: {!}", .{self.system_init_error});
                }
                {
                    zgui.beginDisabled(.{ .disabled = self.system == null });
                    defer zgui.endDisabled();
                    zgui.separatorText("Chaperone");
                    if (self.chaperone) |chaperone| {
                        zgui.beginDisabled(.{ .disabled = true });
                        defer zgui.endDisabled();

                        _ = zgui.inputText("calibration state", .{ .buf = @constCast(@tagName(chaperone.getCalibrationState())) });
                    } else {
                        if (zgui.button("init", .{})) {
                            self.chaperone_init_error = OpenVR.InitError.None;
                            self.chaperone = openvr.chaperone() catch |err| chaperone: {
                                self.chaperone_init_error = err;
                                break :chaperone null;
                            };
                        }
                        zgui.text("init error: {!}", .{self.chaperone_init_error});
                    }
                }
                {
                    zgui.beginDisabled(.{ .disabled = self.system == null or self.chaperone == null });
                    defer zgui.endDisabled();
                    zgui.separatorText("Compositor");
                    if (self.compositor) |compositor| {
                        zgui.beginDisabled(.{ .disabled = true });
                        defer zgui.endDisabled();

                        _ = zgui.checkbox("fullscreen", .{ .v = @constCast(&compositor.isFullscreen()) });
                        _ = zgui.checkbox("motion smoothing enabled", .{ .v = @constCast(&compositor.isMotionSmoothingEnabled()) });
                        _ = zgui.checkbox("motion smoothing supported", .{ .v = @constCast(&compositor.isMotionSmoothingSupported()) });
                    } else {
                        if (zgui.button("init", .{})) {
                            self.compositor_init_error = OpenVR.InitError.None;
                            self.compositor = openvr.compositor() catch |err| compositor: {
                                self.compositor_init_error = err;
                                break :compositor null;
                            };
                        }
                        zgui.text("init error: {!}", .{self.compositor_init_error});
                    }
                }
            } else {
                if (zgui.button("init", .{})) {
                    self.init_error = OpenVR.InitError.None;
                    self.openvr = OpenVR.init(.overlay) catch |err| openvr: {
                        self.init_error = err;
                        break :openvr null;
                    };
                }
                zgui.text("init error: {!}", .{self.init_error});
            }
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
