//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

/// the actual GDT
pub const GDT = packed struct {
    entries: [8]Entry,
};

/// an entry in the GDT
const Entry = packed struct {
    const Self = @This();

    limit_low: u16,
    base_low: u16,
    base_middle: u8,
    access: u8,
    granularity: u8,
    base_high: u8,
};
