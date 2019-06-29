//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const osmium = @import("osmium");
const vga = osmium.driver.vga;

// ngl, zig packages kinda suck
// we need this so zig actually exports the symbols we need
comptime {
    _ = osmium;
}

pub fn main() void {
    vga.write("hello world!");
}
