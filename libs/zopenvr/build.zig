const std = @import("std");
const assert = std.debug.assert;

pub const Package = struct {
    target: std.Build.ResolvedTarget,
    zopenvr: *std.Build.Module,
    install: *std.Build.Step,

    pub fn link(pkg: Package, exe: *std.Build.Step.Compile) void {
        exe.root_module.addImport("zopenvr", pkg.zopenvr);

        exe.step.dependOn(pkg.install);

        switch (pkg.target.result.os.tag) {
            .windows => {
                assert(pkg.target.result.cpu.arch.isX86());

                exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/openvr/lib/win64" });
                exe.linkSystemLibrary("openvr_api");
            },
            .linux => {
                assert(pkg.target.result.cpu.arch.isX86());
                exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/openvr/lib/linux64" });
                exe.linkSystemLibrary("openvr_api");
            },
            .macos => {
                exe.addLibraryPath(.{ .path = thisDir() ++ "/libs/openvr/lib/osx32" });
                exe.linkSystemLibrary("openvr_api");
            },
            else => {},
        }
    }
};

pub fn package(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    _: std.builtin.Mode,
    _: struct {},
) Package {
    const zopenvr = b.addModule("zopenvr", .{
        .root_source_file = .{ .path = thisDir() ++ "/src/zopenvr.zig" },
    });

    const install_step = b.allocator.create(std.Build.Step) catch @panic("OOM");
    install_step.* = std.Build.Step.init(.{ .id = .custom, .name = "zopenvr-install", .owner = b });

    switch (target.result.os.tag) {
        .windows => {
            install_step.dependOn(
                &b.addInstallFile(
                    .{ .path = thisDir() ++ "/libs/openvr/bin/win64/openvr_api.dll" },
                    "bin/openvr_api.dll",
                ).step,
            );
        },
        .linux => {
            install_step.dependOn(
                &b.addInstallFile(
                    .{ .path = thisDir() ++ "/libs/openvr/bin/linux64/libopenvr_api.so" },
                    "bin/libopenvr_api.so.0",
                ).step,
            );
        },
        .macos => {
            install_step.dependOn(
                &b.addInstallFile(
                    .{ .path = thisDir() ++ "/libs/openvr/bin/linux64/libopenvr_api.dylib" },
                    "bin/libopenvr_api.dylib",
                ).step,
            );
        },
        else => {},
    }

    return .{
        .target = target,
        .zopenvr = zopenvr,
        .install = install_step,
    };
}

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});
    const target = b.standardTargetOptions(.{});

    const test_step = b.step("test", "Run zopenvr tests");
    test_step.dependOn(runTests(b, optimize, target));

    _ = package(b, target, optimize, .{});
}

pub fn runTests(
    b: *std.Build,
    optimize: std.builtin.Mode,
    target: std.Build.ResolvedTarget,
) *std.Build.Step {
    const tests = b.addTest(.{
        .name = "zopenvr-tests",
        .root_source_file = .{ .path = thisDir() ++ "/src/zopenvr.zig" },
        .target = target,
        .optimize = optimize,
    });
    const pkg = package(b, target, optimize, .{});
    pkg.link(tests);
    var test_run = b.addRunArtifact(tests);
    switch (target.result.os.tag) {
        .windows => test_run.setCwd(.{ .path = b.getInstallPath(.bin, "") }),
        else => tests.addRPath(.{ .path = b.getInstallPath(.bin, "") }),
    }
    return &test_run.step;
}

inline fn thisDir() []const u8 {
    return comptime std.fs.path.dirname(@src().file) orelse ".";
}
