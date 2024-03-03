const std = @import("std");

const Options = @import("../../build.zig").Options;

pub fn build(b: *std.Build, options: Options) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = "virtual_reality_wgpu",
        .root_source_file = .{ .path = thisDir() ++ "/src/virtual_reality_wgpu.zig" },
        .target = options.target,
        .optimize = options.optimize,
    });

    const zopenvr_pkg = @import("../../build.zig").zopenvr_pkg;
    const zgui_pkg = @import("../../build.zig").zgui_glfw_wgpu_pkg;
    const zgpu_pkg = @import("../../build.zig").zgpu_pkg;

    zopenvr_pkg.link(exe);
    zgui_pkg.link(exe);
    zgpu_pkg.link(exe);

    return exe;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
