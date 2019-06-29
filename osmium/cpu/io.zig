//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const builtin = @import("builtin");
const assert = @import("std").debug.assert;

/// read a byte from the given port
pub inline fn read(io_port: var) u8 {
    const port_info = @typeInfo(@typeOf(io_port));

    comptime assert(
        (port_info == builtin.TypeId.Enum and
            port_info.Enum.tag_type == u16) or
        (port_info == builtin.TypeId.Int and
            port_info.Int.bits == 16),
    );

    const port = switch (port_info) {
        builtin.TypeId.Enum => @enumToInt(io_port),
        builtin.TypeId.Int => io_port,
        else => unreachable,
    };
    
    return asm volatile(
        "inb %[port], %[result]"
        : [result] "={al}" (-> u8)
        : [port] "N{dx}" (port)
    );
}

/// writes a byte to the given port
pub inline fn write(io_port: var, data: var) void {
    const port_info = @typeInfo(@typeOf(io_port));
    const data_info = @typeInfo(@typeOf(data));
    
    comptime assert(
        (port_info == builtin.TypeId.Enum and
            port_info.Enum.tag_type == u16) or
        (port_info == builtin.TypeId.Int and
            port_info.Int.bits == 16),
    );

    comptime assert(
        (data_info == builtin.TypeId.Enum and
            data_info.Enum.tag_type == u8) or
        (data_info == builtin.TypeId.Int and
            data_info.Int.bits == 8),
    );

    const port = switch (port_info) {
        builtin.TypeId.Enum => @enumToInt(io_port),
        builtin.TypeId.Int => io_port,
        else => unreachable,
    };

    const payload = switch (data_info) {
        builtin.TypeId.Enum => @enumToInt(data),
        builtin.TypeId.Int => data,
        else => unreachable,
    };

    asm volatile(
        "outb %[payload], %[port]"
        : 
        : [payload] "{al}" (payload),
            [port] "N{dx}" (port)
    );
}

