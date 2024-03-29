const std = @import("std");
const zgui = @import("zgui");

const OpenVR = @import("zopenvr");

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
        zgui.indent(.{ .indent_w = 30 });
    }

    readOnlyFloat4("m[0]", v.m[0]);
    readOnlyFloat4("m[1]", v.m[1]);
    readOnlyFloat4("m[2]", v.m[2]);

    if (label != null) {
        zgui.unindent(.{ .indent_w = 30 });
        zgui.popId();
    }
}

fn readOnlyMatrix44(label: ?[:0]const u8, v: OpenVR.Matrix44) void {
    if (label) |l| {
        zgui.text("{s}", .{l});

        zgui.pushStrId(l);
        zgui.indent(.{ .indent_w = 30 });
    }

    readOnlyFloat4("m[0]", v.m[0]);
    readOnlyFloat4("m[1]", v.m[1]);
    readOnlyFloat4("m[2]", v.m[2]);
    readOnlyFloat4("m[3]", v.m[3]);

    if (label != null) {
        zgui.unindent(.{ .indent_w = 30 });
        zgui.popId();
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

fn readOnlyFrameTiming(comptime fmt: ?[]const u8, args: anytype, frame_timing: OpenVR.Compositor.FrameTiming) void {
    if (fmt) |f| {
        zgui.text(f, args);
        zgui.indent(.{ .indent_w = 30 });
    }

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

    if (fmt != null) {
        zgui.unindent(.{ .indent_w = 30 });
    }
}

fn renderParams(comptime arg_types: []type, comptime arg_ptrs_info: std.builtin.Type.Struct, arg_ptrs: anytype) void {
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
                OpenVR.InitErrorCode,
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
                OpenVR.System.TrackedPropertyErrorCode,
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

fn renderResult(comptime Return: type, result: Return) void {
    switch (@typeInfo(Return)) {
        .Pointer => |pointer| {
            if (pointer.size == .Slice and pointer.child != u8 and pointer.child != OpenVR.Compositor.FrameTiming) {
                if (result.len > 0) {
                    for (result, 0..) |v, i| {
                        zgui.pushIntId(@intCast(i));
                        defer zgui.popId();
                        renderResult(pointer.child, v);
                        zgui.sameLine(.{});
                        zgui.text("[{}]", .{i});
                    }
                } else {
                    zgui.text("(empty)", .{});
                }
                return;
            }
        },
        .Optional => |optional| {
            if (result) |v| {
                renderResult(optional.child, v);
            } else {
                zgui.text("null", .{});
            }
            return;
        },
        else => {},
    }
    zgui.indent(.{ .indent_w = 30 });
    defer zgui.unindent(.{ .indent_w = 30 });
    switch (Return) {
        bool => readOnlyCheckbox("##", result),
        i32 => readOnlyInt("##", result),
        u32 => readOnlyScalar("##", u32, result),
        u64 => readOnlyScalar("##", u64, result),
        f32 => readOnlyFloat("##", result),
        OpenVR.System.RenderTargetSize => readOnlyScalarN("##", [2]u32, .{
            @as(OpenVR.System.RenderTargetSize, result).width,
            @as(OpenVR.System.RenderTargetSize, result).height,
        }),
        OpenVR.Compositor.FrameTiming => readOnlyFrameTiming(null, .{}, result),
        []OpenVR.Compositor.FrameTiming => {
            if (result.len > 0) {
                for (result, 0..) |frame_timing, i| {
                    readOnlyFrameTiming("[{}]", .{i}, frame_timing);
                }
            } else {
                zgui.text("(empty)", .{});
            }
        },
        [:0]u8, [:0]const u8, []const u8 => readOnlyText("##", result),
        OpenVR.Chaperone.CalibrationState, OpenVR.TrackingUniverseOrigin => readOnlyText("##", @tagName(result)),
        OpenVR.Chaperone.PlayAreaSize => {
            readOnlyFloat("x", result.x);
            readOnlyFloat("z", result.z);
        },
        OpenVR.Quad => {
            readOnlyFloat3("corners[0]", result.corners[0].v);
            readOnlyFloat3("corners[1]", result.corners[1].v);
            readOnlyFloat3("corners[2]", result.corners[2].v);
            readOnlyFloat3("corners[3]", result.corners[3].v);
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
        OpenVR.Vector4 => readOnlyFloat4("##", result.v),
        OpenVR.Matrix34 => readOnlyMatrix34(null, result),
        OpenVR.Matrix44 => readOnlyMatrix44(null, result),
        OpenVR.System.RawProjection => {
            readOnlyFloat("left", result.left);
            readOnlyFloat("right", result.right);
            readOnlyFloat("top", result.top);
            readOnlyFloat("bottom", result.bottom);
        },
        OpenVR.System.DistortionCoordinates => {
            readOnlyFloat2("red", result.red);
            readOnlyFloat2("green", result.green);
            readOnlyFloat2("blue", result.blue);
        },
        else => @compileError(@typeName(Return) ++ " not implemented"),
    }
}

pub fn getter(comptime T: type, comptime f_name: [:0]const u8, self: T, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const f = @field(T, f_name);
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
        renderParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
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

    renderResult(Payload, result);
    zgui.newLine();
}

pub fn staticGetter(comptime T: type, comptime f_name: [:0]const u8, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const f = @field(T, f_name);
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
        inline for (arg_ptrs_info.fields, 0..) |field, i| {
            const arg_ptr = @field(arg_ptrs, field.name);
            args[i] = arg_ptr.*;
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
        renderParams(arg_types[0..], arg_ptrs_info, arg_ptrs);
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

    renderResult(Payload, result);
    zgui.newLine();
}

pub fn allocGetter(allocator: std.mem.Allocator, comptime T: type, comptime f_name: [:0]const u8, self: T, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const f = @field(T, f_name);
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
        renderParams(arg_types[2..], arg_ptrs_info, arg_ptrs);
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
        []OpenVR.Compositor.FrameTiming,
        => allocator.free(result),
        else => @compileError(@typeName(Payload) ++ " not implemented"),
    };

    renderResult(Payload, result);
    zgui.newLine();
}

pub fn setter(comptime T: type, comptime f_name: [:0]const u8, self: T, arg_ptrs: anytype, return_doc: ?[:0]const u8) !void {
    zgui.pushStrId(f_name);
    defer zgui.popId();

    const f = @field(T, f_name);
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
    renderParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
    zgui.text(") {s}", .{return_doc orelse (payload_prefix ++ @typeName(Payload))});

    zgui.newLine();
}
