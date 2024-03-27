const std = @import("std");

pub fn build(b: *std.Build) !void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    _ = b.addModule("root", .{
        .root_source_file = .{ .path = "src/openvr.zig" },
    });

    {
        const unit_tests = b.step("test", "Run zopenvr tests");
        {
            const tests = b.addTest(.{
                .name = "openvr-tests",
                .root_source_file = .{ .path = "src/openvr.zig" },
                .target = target,
                .optimize = optimize,
            });
            try addLibraryPathsTo(tests, "");
            link_OpenVR(tests);
            b.installArtifact(tests);

            const tests_exe = b.addRunArtifact(tests);
            if (target.result.os.tag == .windows) {
                tests_exe.setCwd(.{
                    .path = b.getInstallPath(.bin, ""),
                });
            }
            unit_tests.dependOn(&tests_exe.step);
        }

        try install_OpenVR(unit_tests, target.result, .bin, "");
    }
}

pub fn addLibraryPathsTo(
    compile_step: *std.Build.Step.Compile,
    source_path_prefix: []const u8,
) !void {
    const b = compile_step.step.owner;
    const target = compile_step.rootModuleTarget();
    switch (target.os.tag) {
        .windows => {
            if (target.cpu.arch.isX86()) {
                compile_step.addLibraryPath(.{ .path = try std.fs.path.join(
                    b.allocator,
                    &.{ source_path_prefix, "libs/openvr/lib/win64" },
                ) });
            }
        },
        .linux => {
            if (target.cpu.arch.isX86()) {
                compile_step.addLibraryPath(.{ .path = try std.fs.path.join(
                    b.allocator,
                    &.{ source_path_prefix, "libs/openvr/lib/linux64" },
                ) });
            }
        },
        else => {},
    }
}

pub fn link_OpenVR(compile_step: *std.Build.Step.Compile) void {
    switch (compile_step.rootModuleTarget().os.tag) {
        .windows, .linux => {
            compile_step.linkSystemLibrary("openvr_api");
        },
        else => {},
    }
}

pub fn install_OpenVR(
    step: *std.Build.Step,
    target: std.Target,
    install_dir: std.Build.InstallDir,
    source_path_prefix: []const u8,
) !void {
    const b = step.owner;
    switch (target.os.tag) {
        .windows => {
            if (target.cpu.arch.isX86()) {
                step.dependOn(
                    &b.addInstallFileWithDir(
                        .{ .path = try std.fs.path.join(b.allocator, &.{
                            source_path_prefix,
                            "libs/openvr/bin/win64/openvr_api.dll",
                        }) },
                        install_dir,
                        "openvr_api.dll",
                    ).step,
                );
            }
        },
        .linux => {
            if (target.cpu.arch.isX86()) {
                step.dependOn(
                    &b.addInstallFileWithDir(
                        .{ .path = try std.fs.path.join(b.allocator, &.{
                            source_path_prefix,
                            "libs/openvr/bin/linux64/libopenvr_api.so",
                        }) },
                        install_dir,
                        "libopenvr_api.so.0",
                    ).step,
                );
            }
        },
        else => {},
    }
}
