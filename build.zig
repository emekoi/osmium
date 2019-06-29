//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const builtin = @import("builtin");

const ArrayList = std.ArrayList;

const Builder = std.build.Builder;

pub fn build(builder: *Builder) !void {
    const kernel = builder.addExecutable("kernel", "src/main.zig");
    const mode = builder.standardReleaseOptions();
    builder.setInstallPrefix(".");

    kernel.setTarget(builtin.Arch.i386, builtin.Os.freestanding, builtin.Abi.gnu);
    kernel.setLinkerScriptPath("osmium/linker.ld");
    kernel.setBuildMode(mode);

    std.fs.deleteFile("bin" ++ std.fs.path.sep_str ++ "qemu.log") catch |err| switch (err) {
        error.FileNotFound => {},
        else => return err,
    };

    // adds kernel as an importable package
    kernel.addPackagePath("osmium", "osmium/osmium.zig");

    // add the build step
    qemu_step(builder, "bin/kernel");
    builder.default_step.dependOn(&kernel.step);
    builder.installArtifact(kernel);
}

// adds qemu commands
fn qemu_step(builder: *Builder, osmium: []const u8) void {
    const qemu = builder.step("qemu", "run osmium with qemu");
    const qemu_debug = builder.step("qemu-debug", "run osmium with qemu and wait for debugger to attach");

    const run_qemu = builder.addSystemCommand([_][]const u8{
        "qemu-system-i386",
        "-kernel",
        osmium,
        "-d",
        "cpu_reset",
        "-D",
        "bin/qemu.log",
    });

    const run_qemu_debug = builder.addSystemCommand([_][]const u8{
        "qemu-system-i386",
        "-s",
        "-S",
        "-kernel",
        osmium,
        "-d",
        "cpu_reset",
        "-D",
        "bin/qemu.log",
    });

    run_qemu.step.dependOn(builder.default_step);
    run_qemu_debug.step.dependOn(builder.default_step);

    qemu.dependOn(&run_qemu.step);
    qemu_debug.dependOn(&run_qemu_debug.step);
}
