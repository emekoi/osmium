//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const std = @import("std");
const math = std.math;


pub const Color = struct {
    const Self = @This();
    
    pub r: u8,
    pub g: u8,
    pub b: u8,
    
    pub fn new(r: u8, g: u8, b: u8) Self {
        return Self { .r = r, .g = g, .b = b };
    }
};

pub const Rect = struct {
    const Self = @This();
    
    pub x: u32,
    pub y: u32,
    pub w: u32,
    pub h: u32,
    
    pub fn new(x: u32, y: u32, w: u32, h: u32) Self {
        return Self { .x = x, .y = y, .w = w, .h = h };
    }
};

pub const BlendMode = enum {
    Color,
    Add,
    Subtract,
    Multiply,
    Lighten,
    Darken,
    Screen,
    Difference
};

pub const DrawMode = struct {
    const Self = @This();
    
    pub color: Color,
    pub blend: BlendMode,

    pub fn new(color: Color, blend: BlendMode) Self {
        return Self { .color = color, .blend = blend };
    }
};

pub const Transform = struct {
    const Self = @This();

    pub ox: f32,
    pub oy: f32,
    pub r: f32,
    pub sx: f32,
    pub sy: f32,

    pub fn new(ox: f32, oy: f32, r: f32, sx: f32, sy: f32) Self {
        return Self { .ox = ox, .oy = oy, .r = r, .sx = sx, .sy = sy };
    }
};

pub const Canvas = struct {
    const Self = @This();

    pub mode: DrawMode,
    pub clip: Rect,
    pixels: []Color,
    pub w: u32,
    pub h: u32,
};
