const std = @import("std");
const zgpu = @import("../../libs/zgpu/build.zig");
const zmath = @import("../../libs/zmath/build.zig");
const zpool = @import("../../libs/zpool/build.zig");
const zglfw = @import("../../libs/zglfw/build.zig");
const zgui = @import("../../libs/zgui/build.zig");

const Options = @import("../../build.zig").Options;
const content_dir = "triangle_wgpu_content/";

pub fn build(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const exe = b.addExecutable("triangle_wgpu", thisDir() ++ "/src/triangle_wgpu.zig");

    const exe_options = b.addOptions();
    exe.addOptions("build_options", exe_options);
    exe_options.addOption([]const u8, "content_dir", content_dir);

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = thisDir() ++ "/" ++ content_dir,
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    exe.setBuildMode(options.build_mode);
    exe.setTarget(options.target);

    link(exe, zgpu.BuildOptionsStep.init(b, .{}));

    return exe;
}

pub fn buildTests(b: *std.build.Builder, options: Options) *std.build.LibExeObjStep {
    const tests = b.addTest(thisDir() ++ "/src/triangle_wgpu.zig");
    tests.setBuildMode(options.build_mode);
    tests.setTarget(options.target);

    link(tests, zgpu.BuildOptionsStep.init(b, .{}));

    return tests;
}

fn link(exe: *std.build.LibExeObjStep, zgpu_options: zgpu.BuildOptionsStep) void {
    const zgpu_pkg = zgpu.getPkg(&.{ zgpu_options.getPkg(), zpool.pkg, zglfw.pkg });

    exe.addPackage(zgpu_pkg);
    exe.addPackage(zgui.pkg);
    exe.addPackage(zmath.pkg);
    exe.addPackage(zglfw.pkg);

    zgpu.link(exe, zgpu_options);
    zglfw.link(exe);
    zgui.link(exe);
}
inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
