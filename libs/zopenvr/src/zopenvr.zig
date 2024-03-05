const std = @import("std");

const common = @import("common.zig");

const Self = @This();

pub fn init(application_type: ApplicationType) common.InitError!Self {
    var init_error: common.InitErrorCode = .none;
    _ = VR_InitInternal(&init_error, application_type);
    try init_error.maybe();
    return .{};
}

pub const ApplicationType = enum(i32) {
    other = 0,
    scene = 1,
    overlay = 2,
    background = 3,
    utility = 4,
    vr_monitor = 5,
    steam_watchdog = 6,
    bootstrapper = 7,
    web_helper = 8,
    open_xr_instance = 9,
    open_xr_scene = 10,
    open_xr_overlay = 11,
    prism = 12,
    room_view = 13,
    max = 14,
};
extern fn VR_InitInternal(*common.InitErrorCode, ApplicationType) callconv(.C) *isize;

pub fn deinit(_: Self) void {
    VR_ShutdownInternal();
}
extern fn VR_ShutdownInternal() callconv(.C) void;

test "init/shutdown utility" {
    const instance = try init(.utility);
    defer instance.deinit();
}

pub fn isHmdPresent(_: Self) bool {
    return VR_IsHmdPresent();
}
extern fn VR_IsHmdPresent() callconv(.C) bool;

pub fn isRuntimeInstalled(_: Self) bool {
    return VR_IsRuntimeInstalled();
}
extern fn VR_IsRuntimeInstalled() callconv(.C) bool;

pub fn system(_: Self) common.InitError!System {
    return try System.init();
}

pub fn chaperone(_: Self) common.InitError!Chaperone {
    return try Chaperone.init();
}

pub usingnamespace @import("common.zig");
pub const System = @import("system.zig");
pub const Chaperone = @import("chaperone.zig");
