//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

const osmium = @import("../kernel/index.zig");
const vga = osmium.driver.vga;

pub fn main() void {
    vga.write("hello world!");
}
