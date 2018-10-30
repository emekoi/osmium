//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const builtin = @import("builtin");

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
    pub inline fn read(port: var) u8 {
        const port_info = @typeInfo(port);
        comptime assert(
            port_info == builtin.TypeId.Enum and
            port_info.Enum.tag_type == u16,
        );
        return asm volatile(
            "inb %[port], %[result]"
            : [result] "={al}" (-> u8)
            : [port] "N{dx}" (@enumToInt(port))
        );
    }

    /// writes a byte to the given port
    pub inline fn write(port: var, payload: var) void {
        const port_info = @typeInfo(port);
        const payload_info = @typeInfo(payload);
        comptime assert(
            port_info == builtin.TypeId.Enum and
            port_info.tag_type == u16,
        );
        comptime assert(
            (payload_info == builtin.TypeId.Enum and
                payload_info.Enum.tag_type == u8) or
            (payload_info == builtin.TypeId.Int and
                payload_info.Int.bits == 8),
        );
        asm volatile(
            "outb %[payload], %[port]"
            : 
            : [payload] "{al}" (@enumToInt(payload)),
                [port] "N{dx}" (@enumToInt(port))
        );
    }
};
