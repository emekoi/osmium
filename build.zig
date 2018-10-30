//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const builtin = @import("builtin");

const Builder = std.build.Builder;
const ArrayList = std.ArrayList;

fn build_kernel(builder: *Builder, mode: builtin.Mode) []const u8 {
    const kernel = builder.addObject("boot", "kernel/boot.zig");
    kernel.setLinkerScriptPath("kernel/linker.ld");
    kernel.setBuildMode(mode);
    kernel.setTarget(
        builtin.Arch.i386,
        builtin.Os.freestanding,
        builtin.Environ.gnu
    );

    // add the build step
    builder.default_step.dependOn(&kernel.step);
    return kernel.getOutputPath();
}

pub fn build(builder: *Builder) !void {
    const osmium = builder.addExecutable("bin/osmium", "src/main.zig");
    const mode = builder.standardReleaseOptions();
    try builder.makePath("bin");

    // adds the kernel to the build
    const kernel = build_kernel(builder, mode);
    
    // builds the high level stuff
    osmium.setLinkerScriptPath("kernel/linker.ld");
    osmium.setBuildMode(mode);
    osmium.setTarget(
        builtin.Arch.i386,
        builtin.Os.freestanding,
        builtin.Environ.gnu
    );

    // adds kernel as an importable package
    osmium.addPackagePath("osmium", "kernel/index.zig"); 

    // add the build step
    builder.default_step.dependOn(&osmium.step);
    builder.installArtifact(osmium);


    const qemu = builder.step("qemu", "run the OS with qemu");
    const qemu_debug = builder.step("qemu-debug", "run the OS with qemu and wait for debugger to attach");

    const common_params = [][]const u8.{
        "qemu-system-i386",
        "-kernel", kernel,
        "-d", "cpu_reset",
        "-D", "bin/qemu.log"
    };

    const debug_params = [][]const u8.{"-s", "-S"};

    var qemu_params = ArrayList([]const u8).init(builder.allocator);
    var qemu_debug_params = ArrayList([]const u8).init(builder.allocator);
    
    for (common_params) |p| {
        try qemu_params.append(p);
        try qemu_debug_params.append(p);
    }
    
    for (debug_params) |p| {
        try qemu_debug_params.append(p);
    }

    const run_qemu = builder.addCommand(".", builder.env_map, qemu_params.toSlice());
    const run_qemu_debug = builder.addCommand(".", builder.env_map, qemu_debug_params.toSlice());

    run_qemu.step.dependOn(builder.default_step);
    run_qemu_debug.step.dependOn(builder.default_step);
    qemu.dependOn(&run_qemu.step);
    qemu_debug.dependOn(&run_qemu_debug.step);
}
