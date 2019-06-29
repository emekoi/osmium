//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

/// talking to hardware
pub const driver = @import("driver/index.zig");
pub const cpu = @import("cpu/index.zig");

// ngl, zig packages kinda suck
// we need this so zig actually exports the symbols we need
comptime {
    _ = @import("boot.zig");
}
