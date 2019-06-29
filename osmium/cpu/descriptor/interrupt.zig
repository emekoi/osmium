//  Copyright (c) 2018 emekoi
//
//  This library is free software; you can redistribute it and/or modify it
//  under the terms of the MIT license. See LICENSE for details.
//

/// the actual IDT
pub const IDT = packed struct {
    entries: [256]Entry,
};

/// an entry in the IDT
const Entry = packed struct {
    const Self = @This();

    base_low: u16,
    selector: u16,
    zero: u8,
    flags: u8,
    base_high: u16,
};
