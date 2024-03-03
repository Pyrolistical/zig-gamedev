const std = @import("std");
const zopenvr = @import("zopenvr");

pub fn main() !void {
    const system = zopenvr.init(.overlay) catch |init_error| switch (init_error) {
        error.Init_HmdNotFoundPresenceFailed => @panic(zopenvr.EVRInitError.Init_HmdNotFoundPresenceFailed.asEnglishDescription()),
        error.Init_HmdNotFound => @panic(zopenvr.EVRInitError.Init_HmdNotFound.asEnglishDescription()),
        else => |err| return err,
    };
    defer zopenvr.shutdown();

    std.debug.print("isRuntimeInstalled {}\n", .{zopenvr.isRuntimeInstalled()});
    std.debug.print("isHmdPresent {}\n", .{zopenvr.isHmdPresent()});
    std.debug.print("{s}\n", .{system.getRuntimeVersion()});
}
