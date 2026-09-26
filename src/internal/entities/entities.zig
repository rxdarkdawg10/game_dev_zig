const std = @import("std");
const graphics = @import("../graphics/engine.zig");

pub const Entity = struct {
    text: []u8,
    text_size: f32,
    has_text: bool,
    object: graphics.Rect,
};
