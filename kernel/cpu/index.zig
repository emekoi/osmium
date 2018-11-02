//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

/// reading and writing cpu io ports
pub const io = @import("io.zig");

/// interrupt descriptor table
pub const idt = @import("descriptor/interrupt.zig");

/// global descriptor table
pub const gdt = @import("descriptor/global.zig");

/// halt the cpu
pub inline fn hlt() noreturn {
    while (true) {
        asm volatile("hlt");
    }
}

/// disable interrupts
pub inline fn cli() void {
    asm volatile("cli");
}

/// enable interrupts
pub inline fn sti() void {
    asm volatile("sti");
}

/// completely stop the computer
pub inline fn hang() noreturn {
    cli();
    hlt();
}

/// load the IDT
pub inline fn lidt(id_table: *idt.IDT) void {
    asm volatile(
        "lidt %[idt]"
        :
        : [idt] "r" (id_table)
        : "memory"
    );
}

/// load the GDT
pub inline fn lgdt(gd_table: *gdt.GDT) void {
    asm volatile(
        "lgdt %[gdt]"
        :
        : [gdt] "r" (gd_table)
        : "memory"
    );
}

