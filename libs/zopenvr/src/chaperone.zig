const std = @import("std");

const common = @import("common.zig");

function_table: *FunctionTable,

const Self = @This();

const version = "IVRChaperone_004";
pub fn init() common.InitError!Self {
    return .{
        .function_table = try common.getFunctionTable(FunctionTable, version),
    };
}

pub const CalibrationState = enum(i32) {
    ok = 1,
    warning = 100,
    warning_base_station_may_have_moved = 101,
    warning_base_station_removed = 102,
    warning_seated_bounds_invalid = 103,
    @"error" = 200,
    error_base_station_uninitialized = 201,
    error_base_station_conflict = 202,
    error_play_area_invalid = 203,
    error_collision_bounds_invalid = 204,
};

pub fn getCalibrationState(self: Self) CalibrationState {
    return self.function_table.GetCalibrationState();
}

pub const PlayAreaSize = struct {
    x: f32,
    z: f32,
};
pub fn getPlayAreaSize(self: Self) ?PlayAreaSize {
    var play_area: PlayAreaSize = undefined;
    if (self.function_table.GetPlayAreaSize(&play_area.x, &play_area.y)) {
        return play_area;
    } else {
        return null;
    }
}

pub fn getPlayAreaRect(self: Self) ?common.Quad {
    var play_area: common.Quad = undefined;
    if (self.function_table.GetPlayAreaRect(&play_area)) {
        return play_area;
    } else {
        return null;
    }
}

pub fn reloadInfo(self: Self) void {
    self.function_table.ReloadInfo();
}

pub const Color = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};
pub fn setSceneColor(self: Self, scene_color: Color) void {
    self.function_table.SetSceneColor(scene_color);
}

pub fn getBoundsColor(self: Self, output_colors: []Color, collision_bounds_fade_distance: f32) Color {
    var output_camera_color: Color = undefined;
    self.function_table.GetBoundsColor(output_colors.ptr, output_colors.len, collision_bounds_fade_distance, &output_camera_color);
    return output_camera_color;
}

pub fn areBoundsVisible(self: Self) bool {
    return self.function_table.AreBoundsVisible();
}

pub fn forceBoundsVisible(self: Self, force: bool) void {
    self.function_table.ForceBoundsVisible(force);
}

pub fn resetZeroPose(self: Self, origin: common.TrackingUniverseOrigin) void {
    self.function_table.ResetZeroPose(origin);
}

pub const FunctionTable = extern struct {
    GetCalibrationState: *const fn () callconv(.C) CalibrationState,
    GetPlayAreaSize: *const fn (*f32, *f32) callconv(.C) bool,
    GetPlayAreaRect: *const fn (*common.Quad) callconv(.C) bool,
    ReloadInfo: *const fn () callconv(.C) void,
    SetSceneColor: *const fn (Color) callconv(.C) void,
    GetBoundsColor: *const fn ([*c]Color, c_int, f32, *Color) callconv(.C) void,
    AreBoundsVisible: *const fn () callconv(.C) bool,
    ForceBoundsVisible: *const fn (bool) callconv(.C) void,
    ResetZeroPose: *const fn (common.TrackingUniverseOrigin) callconv(.C) void,
};
