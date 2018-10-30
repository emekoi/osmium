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
    const osmium = builder.addExecutable("osmium", "kernel/boot.zig");
    const mode = builder.standardReleaseOptions();
    
    try builder.makePath("bin");

    std.os.deleteFile("zig-cache" ++ std.os.path.sep_str ++ "qemu.log") catch |err| {
        switch (err) {
            error.FileNotFound => {},
            else => return err,
        }
    };

    builder.setInstallPrefix(".");

    // adds kernel as an importable package
    osmium.addPackagePath("osmium", "kernel/index.zig");
   
    // adds the root file to the kernel as an importable package
    osmium.addPackagePath("@root", "src/main.zig");
    
    osmium.setLinkerScriptPath("kernel/linker.ld");
    osmium.setBuildMode(mode);
    osmium.setTarget(
        builtin.Arch.i386,
        builtin.Os.freestanding,
        builtin.Environ.gnu
    );
    
    // add the build step
    builder.default_step.dependOn(&osmium.step);
    builder.installArtifact(osmium);

    qemu_step(builder, osmium.getOutputPath());
}

// adds qemu commands
fn qemu_step(builder: *Builder, osmium: []const u8) void {
    const qemu = builder.step("qemu", "run osmium with qemu");
    const qemu_debug = builder.step("qemu-debug", "run osmium with qemu and wait for debugger to attach");

    const common_params = [][]const u8.{
        "qemu-system-i386",
        "-kernel", osmium,
        "-d", "cpu_reset",
        "-D", "bin/qemu.log"
    };

    const debug_params = [][]const u8.{
        "qemu-system-i386",
        "-s", "-S", "-kernel",
        osmium, "-d", "cpu_reset",
        "-D", "bin/qemu.log"
    };

    const run_qemu = builder.addCommand(".", builder.env_map, common_params);
    const run_qemu_debug = builder.addCommand(".", builder.env_map, debug_params);

    run_qemu.step.dependOn(builder.default_step);
    run_qemu_debug.step.dependOn(builder.default_step);

    qemu.dependOn(&run_qemu.step);
    qemu_debug.dependOn(&run_qemu_debug.step);
}
