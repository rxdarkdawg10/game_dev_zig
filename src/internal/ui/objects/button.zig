const utils = @import("../../helpers/utils.zig");
const graphics = @import("../../graphics/engine.zig");
const ent = @import("../../entities/entities.zig");
const std = @import("std");

pub const Button = struct {
    text: struct {
        value: []u8,
        color: graphics.Color,
        pos: utils.Vec2,
    },
    color: graphics.Color,
    width: u32,
    height: u32,
    pos: utils.Vec2,
};

pub fn new(elem: Button, alloc: std.mem.Allocator) !ent.Entity {
    const dupe_text = try alloc.dupe(u8, elem.text.value);
    const rect: graphics.Rect = .{ .h = @floatFromInt(elem.height), .w = @floatFromInt(elem.width), .x = elem.pos.x, .y = elem.pos.y };
    const entity = ent.Entity{ .has_text = true, .object = rect, .text = dupe_text };

    return entity;
}
