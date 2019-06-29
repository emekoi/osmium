//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const root = @import("root");
const builtin = @import("builtin");

const osmium = @import("osmium.zig");
const vga = osmium.driver.vga;
const cpu = osmium.cpu;

// multiboot constants
const ALIGN = 1 << 0;
const MEMINFO = 1 << 1;
const FLAGS = ALIGN | MEMINFO;
const MAGIC = 0x1BADB002;

// describes the multiboot header format
const MultiBoot = packed struct {
    magic: c_long,
    flags: c_long,
    checksum: c_long,
};

// our multiboot header
export var multiboot align(4) linksection(".multiboot") = MultiBoot{
    .magic = MAGIC,
    .flags = FLAGS,
    .checksum = -(MAGIC + FLAGS),
};

// our kernel's stack (32 KiB)
export var stack_bytes: [0x8000]u8 align(16) linksection(".bss") = undefined;
// an aligned slice of our kernel's stack (for @newStackCall)
const stack_slice = stack_bytes[0..];

// our panic handler
fn panic(msg: []const u8, error_return_trace: ?*builtin.StackTrace) noreturn {
    @setCold(true);
    vga.Color(vga.Color.Red, vga.Color.White);
    vga.write("\nKERNEL PANIC: ");
    vga.write(msg);
    cpu.hang();
}

// setup useful stuff like the GDT,IDT, etc.
fn _start_body() void {
    vga.init();

    // call and handle the return of different types of main functions
    switch (@typeId(@typeOf(root.main).ReturnType)) {
        builtin.TypeId.NoReturn, builtin.TypeId.Void => {
            @noInlineCall(root.main);
        },
        builtin.TypeId.ErrorUnion => {
            @noInlineCall(root.main) catch |err| {
                vga.write("error: {}\n", @errorName(err));
                if (@errorReturnTrace()) |trace| {
                    // std.debug.dumpStackTrace(trace);
                    panic("", trace);
                }
            };
        },
        else => @compileError("expected return type of main to be 'noreturn', 'void', or '!void'"),
    }
}

// our kernel entry point
export nakedcc fn _start() noreturn {
    // set things up
    @newStackCall(stack_slice, _start_body);
    // hang
    cpu.hang();
}
