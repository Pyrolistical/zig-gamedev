const std = @import("std");

const Options = @import("../../build.zig").Options;

const demo_name = "virtual_reality_d3d12";
const content_dir = demo_name ++ "_content/";

pub fn build(b: *std.Build, options: Options) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .name = demo_name,
        .root_source_file = .{ .path = thisDir() ++ "/src/" ++ demo_name ++ ".zig" },
        .target = options.target,
        .optimize = options.optimize,
    });

    const zgui_pkg = @import("../../build.zig").zgui_glfw_d3d12_pkg;
    const zd3d12_pkg = @import("../../build.zig").zd3d12_pkg;
    const zwin32_pkg = @import("../../build.zig").zwin32_pkg;
    const zglfw_pkg = @import("../../build.zig").zglfw_pkg;
    const zopenvr_pkg = @import("../../build.zig").zopenvr_pkg;

    zgui_pkg.link(exe);
    zd3d12_pkg.link(exe);
    zwin32_pkg.link(exe, .{ .d3d12 = true });
    zglfw_pkg.link(exe);
    zglfw_pkg.link(exe);
    zopenvr_pkg.link(exe);

    const exe_options = b.addOptions();
    exe.root_module.addOptions("build_options", exe_options);
    exe_options.addOption([]const u8, "content_dir", content_dir);

    const install_content_step = b.addInstallDirectory(.{
        .source_dir = .{ .path = thisDir() ++ "/" ++ content_dir },
        .install_dir = .{ .custom = "" },
        .install_subdir = "bin/" ++ content_dir,
    });
    exe.step.dependOn(&install_content_step.step);

    return exe;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
