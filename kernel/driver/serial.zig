//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const cpu = @import("cpu.zig");

// commands to send to serial devices
const Command = enum(u8).{
    LineEnableDLab = 0x80,
};

/// ports for talking to serial devices
pub const Port = enum(u16).{
    const Self = @This();

    Com1 = 0x3F8,
    Com2 = 0x2F8,
    Com3 = 0x3E8,
    Com4 = 0x2E8,

    fn data(self: Self) u16 {
        return @enumToInt(self);
    }

    fn fifo(self: Self) u16 {
        return @enumToInt(self) + 2;
    }

    fn line(self: Self) u16 {
        return @enumToInt(self) + 3;
    }

    fn modem(self: Self) u16 {
        return @enumToInt(self) + 4;
    }

    fn status(self: Self) u16 {
        return @enumToInt(self) + 5;
    }

    // sets speed of data being sent
    fn configureBaud(self: Self, divisor: u16) void {
        cpu.io.write(self.line(), Command.LineEnableDLab);
        cpu.io.write(self.data(), @truncate(u8, divisor >> 8));
        cpu.io.write(self.data(), @truncate(u8, divisor));
    }

    // configures properties of the given serial port
    fn configureLine(self: Self) void {
        // data length of 8 bits, no parity bits,
        // one stop bit, and break control disabled
        cpu.io.write(port.line(), 0x03);
    }

    // configure the port's fifo queues
    fn configureFifo(self: Self) void {
        // enable FIFO, clear reciever and transmission queues,
        // and use 14 bytes as the queue size
        cpu.io.write(self.fifo(), 0xC7);
    }
    
    // tell port we are ready to send data
    fn configureModem(self: Self) void {
        // set RTS and DTR
        cpu.io.write(self.modem(), 0x03);
    }

    /// set thing up to use this port
    pub fn init(self: Self, baud_rate: u16) void {
        self.configureBaud(baud_rate);
        self.configureLine();
        self.configureFifo();
        self.configureModem();
    }
        
    // is there data to be read on this port?
    fn isEmpty(self: Self) bool {
        return (cpu.io.read(self.status()) and 0x20) != 0;
    }

    pub fn putChar(self: Self, char: u8) void {
        while (!self.isEmpty()) {
            asm volatile ("pause");
        }
        cpu.io.write(self.data(), char);
    }

    pub fn write(self: Self, str: []const u8) void {
        for (str) |char| {
            self.putChar(char);
        }
    }
};

