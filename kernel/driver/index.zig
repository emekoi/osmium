//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

/// talking to the cpu, device ports, and whatnot
pub const cpu = @import("cpu.zig");

/// talking to the vga text buffer
pub const vga = @import("vga.zig");

/// talking to serial devices
pub const serial = @import("serial.zig");
