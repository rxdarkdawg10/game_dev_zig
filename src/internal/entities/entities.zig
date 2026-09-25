const std = @import("std");
const graphics = @import("../graphics/engine.zig");

pub const Entity = struct {
    text: []u8,
    has_text: bool,
    object: graphics.Rect,
};
