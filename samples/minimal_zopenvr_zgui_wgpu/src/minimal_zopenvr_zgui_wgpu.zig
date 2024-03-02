const std = @import("std");
const zopenvr = @import("zopenvr");

pub fn main() !void {
    _ = zopenvr.init(.overlay) catch |init_error| switch (init_error) {
        error.Init_HmdNotFoundPresenceFailed => @panic(zopenvr.EVRInitError.Init_HmdNotFoundPresenceFailed.asEnglishDescription()),
        error.Init_HmdNotFound => @panic(zopenvr.EVRInitError.Init_HmdNotFound.asEnglishDescription()),
        else => |err| return err,
    };
    defer zopenvr.shutdown();

    std.debug.print("{}\n", .{zopenvr.isHmdPresent()});
}
