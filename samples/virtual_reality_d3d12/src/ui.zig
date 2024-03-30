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

fn readOnlyMatrix34(v: OpenVR.Matrix34) void {
    readOnlyFloat4("m[0]", v.m[0]);
    readOnlyFloat4("m[1]", v.m[1]);
    readOnlyFloat4("m[2]", v.m[2]);
}

fn readOnlyMatrix44(v: OpenVR.Matrix44) void {
    readOnlyFloat4("m[0]", v.m[0]);
    readOnlyFloat4("m[1]", v.m[1]);
    readOnlyFloat4("m[2]", v.m[2]);
    readOnlyFloat4("m[3]", v.m[3]);
}

fn readOnlyFloat4(label: [:0]const u8, v: [4]f32) void {
    _ = zgui.inputFloat4(label, .{ .v = @constCast(&v), .flags = .{ .read_only = true } });
}

fn readOnlyColor4(label: [:0]const u8, v: [4]f32) void {
    zgui.beginDisabled(.{ .disabled = true });
    defer zgui.endDisabled();
    _ = zgui.colorEdit4(label, .{ .col = @constCast(&v), .flags = .{ .float = true } });
}

fn readOnlyTrackedDevicePoses(poses: []OpenVR.TrackedDevicePose) void {
    if (poses.len > 0) {
        for (poses, 0..) |pose, i| {
            zgui.pushIntId(@intCast(i));
            defer zgui.popId();
            {
                zgui.text("[{}]", .{i});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePose(pose);
            }
        }
    } else {
        zgui.text("(empty)", .{});
    }
}

fn readOnlyTrackedDevicePose(pose: OpenVR.TrackedDevicePose) void {
    if (pose.pose_is_valid) {
        {
            zgui.text("device_to_absolute_tracking", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });
            readOnlyMatrix34(pose.device_to_absolute_tracking);
        }

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
    {
        zgui.text("pose", .{});
        zgui.indent(.{ .indent_w = 30 });
        defer zgui.unindent(.{ .indent_w = 30 });
        readOnlyTrackedDevicePose(frame_timing.pose);
    }
    readOnlyScalar("num_v_syncs_ready_for_use", u32, frame_timing.num_v_syncs_ready_for_use);
    readOnlyScalar("num_v_syncs_to_first_view", u32, frame_timing.num_v_syncs_to_first_view);
}

fn readOnlyEvent(event: OpenVR.System.Event) void {
    readOnlyText("event_type", @tagName(event.event_type));
    readOnlyScalar("tracked_device_index", u32, event.tracked_device_index);
    readOnlyFloat("event_age_seconds", event.event_age_seconds);

    switch (event.event_type) {
        .none,
        .tracked_device_activated,
        .tracked_device_deactivated,
        .tracked_device_updated,
        .tracked_device_user_interaction_started,
        .tracked_device_user_interaction_ended,
        .enter_standby_mode,
        .leave_standby_mode,
        .tracked_device_role_changed,
        .watchdog_wake_up_requested,
        .lens_distortion_changed,
        .wireless_disconnect,
        .wireless_reconnect,
        .reserved_01,
        .reserved_02,
        => {},
        .ipd_changed => {}, // should be EventIpd?
        // .ipd_changed => {
        //     const data = event.data.ipd;
        //     zgui.text("data.ipd", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyFloat("ipd_meters", data.ipd_meters);
        // },
        .property_changed => {}, // should be EventProperty?
        // .property_changed=>{
        //     const data = event.data.property;
        //     zgui.text("data.property", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyScalar("container", u64, data.container);
        //     readOnlyText("prop", @tagName(data.prop));
        // },
        .button_press,
        .button_unpress,
        .button_touch,
        .button_untouch,
        => {
            const data = event.data.controller;
            zgui.text("data.controller", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("button", u32, data.button);
        },
        .modal_cancel,
        .focus_enter,
        .focus_leave,
        .overlay_focus_changed,
        .dashboard_requested,
        .reset_dashboard,
        .image_loaded,
        => {
            const data = event.data.overlay;
            zgui.text("data.overlay", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("overlay_handle", u64, data.overlay_handle);
            readOnlyScalar("device_path", u64, data.device_path);
            readOnlyScalar("memory_block_id", u64, data.memory_block_id);
            readOnlyScalar("cursor_index", u32, data.cursor_index);
        },
        .mouse_move,
        .mouse_button_down,
        .mouse_button_up,
        .touch_pad_move, // should be EventTouchPadMove?
        .lock_mouse_position,
        .unlock_mouse_position,
        => {
            const data = event.data.mouse;
            zgui.text("data.mouse", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyFloat("x", data.x);
            readOnlyFloat("y", data.y);
            readOnlyScalar("button", u32, data.button);
            readOnlyScalar("cursor_index", u32, data.cursor_index);
        },
        // .touch_pad_move => {
        //     const data = event.data.touch_pad_move;
        //     zgui.text("data.touch_pad_move", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyCheckbox("finder_down", data.finder_down);
        //     readOnlyFloat("seconds_finder_down", data.seconds_finder_down);
        //     readOnlyFloat("x_first", data.x_first);
        //     readOnlyFloat("y_first", data.y_first);
        //     readOnlyFloat("x_raw", data.x_raw);
        //     readOnlyFloat("y_raw", data.y_raw);
        // },
        .scroll_discrete,
        .scroll_smooth,
        => {
            const data = event.data.scroll;
            zgui.text("data.scroll", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyFloat("x_delta", data.x_delta);
            readOnlyFloat("y_delta", data.y_delta);
            readOnlyScalar("unused", u32, data.unused);
            readOnlyFloat("viewport_scale", data.viewport_scale);
            readOnlyScalar("cursor_index", u32, data.cursor_index);
        },
        .reload_overlays,
        .input_focus_captured, // deprecated
        .input_focus_released, // deprecated
        .scene_application_changed,
        .input_focus_changed,
        .scene_application_using_wrong_graphics_adapter,
        .action_binding_reloaded,
        .scene_app_pipe_disconnected,
        .quit,
        .process_quit,
        .quit_acknowledged,
        .monitor_show_headset_view,
        .monitor_hide_headset_view,
        => {
            const data = event.data.process;
            zgui.text("data.process", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("pid", u32, data.pid);
            readOnlyScalar("old_pid", u32, data.old_pid);
            readOnlyCheckbox("forced", data.forced);
            readOnlyCheckbox("connection_lost", data.connection_lost);
        },
        .hide_render_models,
        .show_render_models,
        .scene_application_state_changed, // see OpenVR.Applications.getSceneApplicationState()
        => {},
        .console_opened,
        .console_closed,
        .overlay_shown, // OpenVR.Overlay.isOverlayVisible() is true
        .overlay_hidden, // OpenVR.Overlay.isOverlayVisible() is false
        .dashboard_activated,
        .dashboard_deactivated,
        .show_keyboard,
        .hide_keyboard,
        .overlay_gamepad_focus_gained,
        .overlay_gamepad_focus_lost,
        .overlay_shared_texture_changed,
        .screenshot_triggered,
        .image_failed,
        .dashboard_overlay_created,
        .switch_gamepad_focus,
        .request_screenshot,
        .screenshot_taken,
        .screenshot_failed,
        .submit_screenshot_to_dashboard,
        .primary_dashboard_device_changed,
        .room_view_shown,
        .room_view_hidden,
        => {},
        .screenshot_progress_to_dashboard => {}, // should be EventScreenshotProgress?
        // .screenshot_progress_to_dashboard=> {
        //     const data = event.data.screenshot_progress;
        //     zgui.text("data.screenshot_progress", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyFloat("progress", data.progress);
        // },
        .show_ui => {
            const data = event.data.show_ui;
            zgui.text("data.show_ui", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyText("type", @tagName(data.type));
        },
        .show_dev_tools => {
            const data = event.data.show_dev_tools;
            zgui.text("data.show_dev_tools", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyInt("browser_identifier", data.browser_identifier);
        },
        .desktop_view_updating,
        .desktop_view_ready,
        .start_dashboard,
        .elevate_prism,
        .overlay_closed,
        .dashboard_thumb_changed,
        .desktop_might_be_visible,
        .desktop_might_be_hidden,
        .notification_shown,
        .notification_hidden,
        .notification_begin_interaction,
        .notification_destroyed,
        => {},
        .driver_requested_quit,
        .restart_requested,
        .invalidate_swap_texture_sets,
        .chaperone_data_has_changed,
        .chaperone_temp_data_has_changed,
        .chaperone_settings_have_changed,
        .chaperone_flush_cache,
        .chaperone_room_setup_starting,
        .chaperone_room_setup_finished,
        .standing_zero_pose_reset,
        .audio_settings_have_changed,
        .background_setting_has_changed,
        .camera_settings_have_changed,
        .reprojection_setting_has_changed,
        .model_skin_settings_have_changed,
        .environment_settings_have_changed,
        .power_settings_have_changed,
        .enable_home_app_settings_have_changed,
        .steam_vr_section_setting_changed,
        .lighthouse_section_setting_changed,
        .null_section_setting_changed,
        .user_interface_section_setting_changed,
        .notifications_section_setting_changed,
        .keyboard_section_setting_changed,
        .perf_section_setting_changed,
        .dashboard_section_setting_changed,
        .web_interface_section_setting_changed,
        .trackers_section_setting_changed,
        .last_known_section_setting_changed,
        .dismissed_warnings_section_setting_changed,
        .gpu_speed_section_setting_changed,
        .windows_mr_section_setting_changed,
        .other_section_setting_changed,
        .any_driver_settings_changed,
        .status_update,
        .web_interface_install_driver_completed,
        .mc_image_updated,
        .firmware_update_started,
        .firmware_update_finished,
        .keyboard_closed, // deprecated
        .keyboard_done,
        .keyboard_opened_global,
        .keyboard_closed_global,
        .application_list_updated,
        .application_mime_type_load,
        .process_connected,
        .process_disconnected,
        .compositor_chaperone_bounds_shown,
        .compositor_chaperone_bounds_hidden,
        .compositor_display_disconnected,
        .compositor_display_reconnected,
        => {},
        .chaperone_universe_has_changed => {}, // should be EventChaperone?
        // .chaperone_universe_has_changed=> {
        //     const data = event.data.chaperone;
        //     zgui.text("data.chaperone", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyScalar("previous_universe", u64, data.previous_universe);
        //     readOnlyScalar("current_universe", u64, data.current_universe);
        // },
        .keyboard_char_input => {}, // should be EventKeyboard?
        // .keyboard_char_input => {
        //     const data = event.data.keyboard;
        //     zgui.text("data.keyboard", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyScalar("new_input[0]", u8, data.new_input[0]);
        //     readOnlyScalar("new_input[1]", u8, data.new_input[1]);
        //     readOnlyScalar("new_input[2]", u8, data.new_input[2]);
        //     readOnlyScalar("new_input[3]", u8, data.new_input[3]);
        //     readOnlyScalar("new_input[4]", u8, data.new_input[4]);
        //     readOnlyScalar("new_input[5]", u8, data.new_input[5]);
        //     readOnlyScalar("new_input[6]", u8, data.new_input[6]);
        //     readOnlyScalar("new_input[7]", u8, data.new_input[7]);
        //     readOnlyScalar("user_value", u64, data.user_value);
        //     readOnlyScalar("overlay_handle", u64, data.overlay_handle);
        // },
        .seated_zero_pose_reset => {}, // should be EventSeatedZeroPoseReset?
        // .seated_zero_pose_reset => {
        //     const data = event.data.seated_zero_pose_reset;
        //     zgui.text("data.seated_zero_pose_reset", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyCheckbox("reset_by_system_menu", data.reset_by_system_menu);
        // },
        .compositor_hdcp_error => {
            const data = event.data.hdcp_error;
            zgui.text("data.hdcp_error", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyText("code", @tagName(data.code));
        },
        .compositor_application_not_responding,
        .compositor_application_resumed,
        .compositor_out_of_video_memory,
        .compositor_display_mode_not_supported,
        .compositor_stage_override_ready,
        .compositor_request_disconnect_reconnect,
        .tracked_camera_start_video_stream,
        .tracked_camera_stop_video_stream,
        .tracked_camera_pause_video_stream,
        .tracked_camera_resume_video_stream,
        .performance_test_enable_capture,
        .performance_test_disable_capture,
        .message_overlay_closed,
        .message_overlay_close_requested,
        => {},
        .performance_test_fidelity_level => {}, // should be EventPerformanceTest?
        // .performance_test_fidelity_level => {
        //     const data = event.data.performance_test;
        //     zgui.text("data.performance_test", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyScalar("fidelity_level", u32, data.fidelity_level);
        // },
        .tracked_camera_editing_surface => {}, // should be EventEditingCameraSurface?
        // .tracked_camera_editing_surface => {
        //     const data = event.data.camera_surface;
        //     zgui.text("data.camera_surface", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyScalar("overlay_handle", u64, data.overlay_handle);
        //     readOnlyScalar("visual_mode", u32, data.visual_mode);
        // },
        .input_haptic_vibration => {
            const data = event.data.haptic_vibration;
            zgui.text("data.haptic_vibration", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("container_handle", u64, data.container_handle);
            readOnlyScalar("component_handle", u64, data.component_handle);
            readOnlyFloat("duration_seconds", data.duration_seconds);
            readOnlyFloat("frequency", data.frequency);
            readOnlyFloat("amplitude", data.amplitude);
        },
        .input_binding_load_failed,
        .input_binding_load_successful,
        => {
            const data = event.data.input_binding;
            zgui.text("data.input_binding", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("app_container", u64, data.app_container);
            readOnlyScalar("path_message", u64, data.path_message);
            readOnlyScalar("path_url", u64, data.path_url);
            readOnlyScalar("path_controller_type", u64, data.path_controller_type);
        },
        .input_action_manifest_reloaded => {},
        .input_action_manifest_load_failed => {
            const data = event.data.action_manifest;
            zgui.text("data.action_manifest", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("path_app_key", u64, data.path_app_key);
            readOnlyScalar("path_message", u64, data.path_message);
            readOnlyScalar("path_message_param", u64, data.path_message_param);
            readOnlyScalar("path_manifest_path", u64, data.path_manifest_path);
        },
        .input_progress_update => {
            const data = event.data.progress_update;
            zgui.text("data.progress_update", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("application_property_container", u64, data.application_property_container);
            readOnlyScalar("path_device", u64, data.path_device);
            readOnlyScalar("path_input_source", u64, data.path_input_source);
            readOnlyScalar("path_progress_action", u64, data.path_progress_action);
            readOnlyScalar("path_icon", u64, data.path_icon);
            readOnlyFloat("progress", data.progress);
        },
        .input_tracker_activated,
        .input_bindings_updated,
        .input_binding_subscription_changed,
        => {},
        .spatial_anchors_pose_updated,
        .spatial_anchors_descriptor_updated,
        .spatial_anchors_request_pose_update,
        .spatial_anchors_request_descriptor_update,
        => {
            const data = event.data.spatial_anchor;
            zgui.text("data.spatial_anchor", .{});
            zgui.indent(.{ .indent_w = 30 });
            defer zgui.unindent(.{ .indent_w = 30 });

            readOnlyScalar("handle", u32, data.handle);
        },
        .system_report_started => {},
        .audio_set_speakers_volume,
        .audio_set_microphone_volume,
        => {}, // should be EventAudioVolumeControl?
        // .audio_set_speakers_volume,
        // .audio_set_microphone_volume,
        // => {
        //     const data = event.data.audio_volume_control;
        //     zgui.text("data.audio_volume_control", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyFloat("volume_level", data.volume_level);
        // },
        .audio_set_speakers_mute,
        .audio_set_microphone_mute,
        => {}, // should be EventAudioMuteControl?
        // .audio_set_speakers_mute,
        // .audio_set_microphone_mute,
        // => {
        //     const data = event.data.audio_mute_control;
        //     zgui.text("data.audio_mute_control", .{});
        //     zgui.indent(.{ .indent_w = 30 });
        //     defer zgui.unindent(.{ .indent_w = 30 });

        //     readOnlyCheckbox("mute", data.mute);
        // },
        .vendor_specific_reserved_start,
        .vendor_specific_reserved_end,
        => {},
    }
}

fn readOnlyControllerState(controller_state: OpenVR.System.ControllerState) void {
    readOnlyScalar("packet_num", u32, controller_state.packet_num);
    readOnlyScalar("button_pressed", u64, controller_state.button_pressed);
    readOnlyScalar("button_touched", u64, controller_state.button_touched);
    zgui.text("axis", .{});
    zgui.indent(.{ .indent_w = 30 });
    defer zgui.unindent(.{ .indent_w = 30 });
    for (controller_state.axis, 0..) |axis, i| {
        zgui.pushIntId(@intCast(i));
        defer zgui.popId();
        zgui.text("[{}]", .{i});
        zgui.indent(.{ .indent_w = 30 });
        defer zgui.unindent(.{ .indent_w = 30 });
        readOnlyFloat("x", axis.x);
        readOnlyFloat("y", axis.y);
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
                u16 => {
                    _ = zgui.inputScalar(arg_name, u16, .{
                        .v = arg_ptr,
                        .step = 1,
                    });
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
                OpenVR.System.EventType,
                OpenVR.System.HiddenAreaMeshType,
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
                    zgui.indent(.{ .indent_w = 30 });
                    defer zgui.unindent(.{ .indent_w = 30 });
                    zgui.text("(empty)", .{});
                }
                return;
            }
        },
        .Optional => |optional| {
            if (result) |v| {
                renderResult(optional.child, v);
            } else {
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });
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
        OpenVR.Compositor.FrameTiming => readOnlyFrameTiming(result),
        []OpenVR.Compositor.FrameTiming => {
            if (result.len > 0) {
                for (result, 0..) |frame_timing, i| {
                    zgui.text("[{}]", .{i});
                    zgui.indent(.{ .indent_w = 30 });
                    defer zgui.unindent(.{ .indent_w = 30 });

                    readOnlyFrameTiming(frame_timing);
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
            {
                zgui.text("render_pose", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePose(result.render_pose);
            }
            {
                zgui.text("game_pose", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePose(result.game_pose);
            }
        },
        OpenVR.Compositor.Poses => {
            {
                zgui.text("render_poses", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });
                readOnlyTrackedDevicePoses(result.render_poses);
            }
            {
                zgui.text("game_poses", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePoses(result.game_poses);
            }
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
        OpenVR.System.Vector2 => readOnlyFloat2("##", result.v),
        OpenVR.Vector4 => readOnlyFloat4("##", result.v),
        OpenVR.Matrix34 => readOnlyMatrix34(result),
        OpenVR.Matrix44 => readOnlyMatrix44(result),
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
        OpenVR.System.Event => readOnlyEvent(result),
        OpenVR.System.EventWithPose => {
            {
                zgui.text("event", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyEvent(result.event);
            }
            {
                zgui.text("pose", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePose(result.pose);
            }
        },
        OpenVR.System.ControllerState => readOnlyControllerState(result),
        OpenVR.System.ControllerStateWithPose => {
            {
                zgui.text("controller_state", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyControllerState(result.controller_state);
            }
            {
                zgui.text("pose", .{});
                zgui.indent(.{ .indent_w = 30 });
                defer zgui.unindent(.{ .indent_w = 30 });

                readOnlyTrackedDevicePose(result.pose);
            }
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

    {
        const payload_prefix = switch (return_type_info) {
            .ErrorUnion => "!",
            else => "",
        };
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

pub fn persistedGetter(comptime T: type, comptime f_name: [:0]const u8, self: T, arg_ptrs: anytype, comptime Payload: type, result_ptr: *?Payload, return_doc: ?[:0]const u8) !void {
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

    if (Return != Payload) {
        @compileError("expected return type of " ++ f_name ++ " " ++ @typeName(Payload) ++ " but was " ++ @typeName(Return));
    }

    if (zgui.button(f_name, .{})) {
        result_ptr.* = @call(.auto, f, args);
    }

    zgui.sameLine(.{});
    zgui.text("(", .{});
    renderParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
    zgui.text(") {s}", .{return_doc orelse @typeName(Payload)});

    if (result_ptr.*) |result| {
        renderResult(Payload, result);
    }
    zgui.newLine();
}

pub fn allocPersistedGetter(allocator: std.mem.Allocator, comptime T: type, comptime f_name: [:0]const u8, self: T, arg_ptrs: anytype, comptime Payload: type, result_ptr: *?Payload, return_doc: ?[:0]const u8) !void {
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
    const ActualPayload = return_type_info.ErrorUnion.payload;

    if (ActualPayload != Payload) {
        @compileError("expected return type of " ++ f_name ++ " " ++ @typeName(Payload) ++ " but was " ++ @typeName(ActualPayload));
    }

    if (zgui.button(f_name, .{})) {
        if (result_ptr.*) |result| {
            switch (Payload) {
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
            }
        }
        result_ptr.* = try @call(.auto, f, args);
    }

    zgui.sameLine(.{});
    zgui.text("(", .{});
    renderParams(arg_types[2..], arg_ptrs_info, arg_ptrs);
    zgui.text(") {s}", .{return_doc orelse ("!" ++ @typeName(Payload))});

    if (result_ptr.*) |result| {
        renderResult(Payload, result);
    }
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

    {
        const payload_prefix = switch (return_type_info) {
            .ErrorUnion => "!",
            else => "",
        };
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

    const Payload = f_info.return_type.?;
    if (@typeInfo(Payload) != .Void) {
        @compileError("expected return type of " ++ f_name ++ " to be void, but was " ++ @typeInfo(Payload));
    }

    if (zgui.button(f_name, .{})) {
        @call(.auto, f, args);
    }
    zgui.sameLine(.{});
    zgui.text("(", .{});
    renderParams(arg_types[1..], arg_ptrs_info, arg_ptrs);
    zgui.text(") {s}", .{return_doc orelse @typeName(Payload)});

    zgui.newLine();
}
