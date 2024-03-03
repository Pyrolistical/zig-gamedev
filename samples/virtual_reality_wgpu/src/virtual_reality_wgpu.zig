const std = @import("std");
const zopenvr = @import("zopenvr");

pub fn main() !void {
    zopenvr.init(.overlay) catch |init_error| switch (init_error) {
        error.InitHmdNotFoundPresenceFailed => @panic(zopenvr.InitErrorCode.init_hmd_not_found_presence_failed.asEnglishDescription()),
        error.InitHmdNotFound => @panic(zopenvr.InitErrorCode.init_hmd_not_found.asEnglishDescription()),
        else => |err| return err,
    };
    defer zopenvr.shutdown();

    const system = try zopenvr.System.init();
    std.debug.print("isRuntimeInstalled {}\n", .{zopenvr.isRuntimeInstalled()});
    std.debug.print("isHmdPresent {}\n", .{zopenvr.isHmdPresent()});
    std.debug.print("{s}\n", .{system.getRuntimeVersion()});
}
