//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const cpu = @import("../cpu/index.zig");

/// commands to send to the vga device cursor
pub const Command = enum(u8) {
    High = 0xE,
    Low = 0xF,
};

/// ports for talking to the vga device cursor
pub const Port = enum(u16) {
    Command = 0x3D4,
    Data = 0x3D5,
};

/// colors for outputting text to the vga device
pub const Color = enum(u8) {
    Black = 0,
    Blue = 1,
    Green = 2,
    Cyan = 3,
    Red = 4,
    Magenta = 5,
    Brown = 6,
    LightGrey = 7,
    DarkGrey = 8,
    LightBlue = 9,
    LightGreen = 10,
    LightCyan = 11,
    LightRed = 12,
    LightMagenta = 13,
    Yellow = 14,
    White = 15
};

/// the height of the vga textbuffer
pub const width = 80;

/// the width of the vga textbuffer
pub const height = 25;

// escape codes for strings
const ESCAPES = []u8 { '\n', '\r', '\t' };

// an array mapped to the textbuffer
var buffer_ptr = @intToPtr([*]volatile u16, 0xB8000);
var buffer = buffer_ptr[0..width * height];

// the current row of the textbuffer's cursor
var row: usize = 0;

// the current column of the textbuffer's cursor
var column: usize = 0;

// the current textbuffer background color
var background_color: Color = Color.LightGrey;

// the current textbuffer foregorund color 
var foreground_color: Color = Color.Black;

// the u8 that represents the current foreground and background color
var color_byte: u8 = 0;

// returns a u8 that represents the given foreground and background color
fn entryColor(fg: Color, bg: Color) u8 {
    return @enumToInt(fg) | (@enumToInt(bg) << 4);
}

// returns a u16 that represents the given char and it's color 
fn entry(char: u8, color: u8) u16 {
    return @intCast(u16, char) | (@intCast(u16, color) << 8);
}

fn moveCursor(x: usize, y: usize) void {
    const pos = @intCast(u16, y * width + x);
    cpu.io.write(Port.Command, Command.High);
    cpu.io.write(Port.Data, @truncate(u8, pos >> 8));
    cpu.io.write(Port.Command, Command.Low);
    cpu.io.write(Port.Data, @truncate(u8, pos));
}

// updates the cursor's positon
fn updateCursor() void {
    moveCursor(column, row);
}

/// clears the textbuffer
pub fn clear() void {
    for (buffer) |*byte| {
        byte.* = entry(' ', color_byte);
    }
}

/// init everything we need to use the textbuffer
pub fn init() void {
    color_byte = entryColor(foreground_color, background_color);
    clear();
    updateCursor();
}

/// sets the textbuffer's foreground color
pub fn setForeGroundColor(color: Color) void {
    foreground_color = color;
    color_byte = entryColor(foreground_color, background_color);
}

/// returns the current foreground color
pub fn getForeGroundColor(color: Color) usize {
    return foreground_color;
}

/// sets the textbuffer's background color
pub fn setBackGroundColor(color: Color) void {
    background_color = color;
    color_byte = entryColor(foreground_color, background_color);
}

/// returns the current background color
pub fn getBackGroundColor(color: Color) usize {
    return background_color;
}

/// set the foreground and background color at once
pub fn setColor(fg: Color, bg: Color) void {
    foreground_color = fg;
    background_color = bg;
    color_byte = entryColor(foreground_color, background_color);
}

/// try to set the cursor's row
pub fn setRow(row: usize) !void {
    if (row > (width - 1)) {
        return error.OutOfBounds;
    }
    updateCursor();
}

/// get the cursor's current row
pub fn getRow() usize {
    return row;
}

/// try to set the cursor's column
pub fn setColumn(column: usize) !void {
    if (column > (height - 1)) {
        return error.OutOfBounds;
    }
    updateCursor();
}

/// get the cursor's current column
pub fn getColumn() usize {
    return column;
}

// set the textbuffer entry at (x, y)
fn putEntryAt(char: u8, x: usize, y: usize) void {
    buffer[y * width + x] = entry(char, color_byte);
}

// handles our escape sequences
fn handleEscape(char: u8) bool {
    switch (char) {
        '\n' => {
            row += 1;
            column = 0;
        },
        '\r' => {
            column = 0;
            const offset = row * width + column;
            for (buffer[offset..(offset + width + 1)]) |*byte| {
                // byte.* = entry(' ', byte_color);
                byte.* = entry(' ', @enumToInt(Color.Brown));
            }
        },
        '\t' => {
            column += 4;
        },
        else => return false,
    }
    return true;
}

/// place a char in the textbuffer
pub fn putChar(char: u8) void {
    // handle escapes
    if (!handleEscape(char)) {
        putEntryAt(char, column, row);
        column += 1;
    }

    // handle newlines/line breaks
    if (column >= width) {
        column = 0;
        row += 1;
    }

    // handle scrolling
    if (row >= height) {
        const blank = entry(' ', color_byte);
        const line = (height - 1) * width;

        for (buffer[0..line]) |*byte, idx| {
            byte.* = buffer[idx + 80];
        }

        for (buffer[line..(width * height)]) |*byte| {
            byte.* = blank;
        }

        row = height - 1;
    }

    // move the cursor as needed
    updateCursor();
}


/// write a string to the textbuffer
pub fn write(data: []const u8) void {
    for (data) |char| {
        putChar(char);
    }
}
