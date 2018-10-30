//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const builtin = @import("builtin");
const assert = @import("std").debug.assert;

/// halt the cpu
pub inline fn hlt() noreturn {
    while (true) {
        asm volatile ("hlt");
    }
}

/// disable interrupts
pub inline fn cli() void {
    asm volatile ("cli");
}

/// enable interrupts
pub inline fn sti() void {
    asm volatile ("sti");
}

/// completely stop the computer
pub inline fn hang() noreturn {
    cli();
    hlt();
}

pub const port = struct.{
    /// read a byte from the given port
    pub inline fn read(cpu_port: var) u8 {
        const port_info = @typeInfo(@typeOf(cpu_port));
        comptime assert(
            port_info == builtin.TypeId.Enum and
            port_info.Enum.tag_type == u16,
        );
        return asm volatile(
            "inb %[port], %[result]"
            : [result] "={al}" (-> u8)
            : [cpu_port] "N{dx}" (@enumToInt(cpu_port))
        );
    }

    /// writes a byte to the given port
    pub inline fn write(cpu_port: var, data: var) void {
        const port_info = @typeInfo(@typeOf(cpu_port));
        const data_info = @typeInfo(@typeOf(data));
        comptime assert(
            port_info == builtin.TypeId.Enum and
            port_info.Enum.tag_type == u16,
        );
        comptime assert(
            (data_info == builtin.TypeId.Enum and
                data_info.Enum.tag_type == u8) or
            (data_info == builtin.TypeId.Int and
                data_info.Int.bits == 8),
        );

        const payload = switch (data_info) {
            builtin.TypeId.Enum => @enumToInt(data),
            builtin.TypeId.Int => data,
            else => unreachable,
        };

        asm volatile(
            "outb %[payload], %[port]"
            : 
            : [payload] "{al}" (payload),
                [port] "N{dx}" (@enumToInt(cpu_port))
        );
    }
};
