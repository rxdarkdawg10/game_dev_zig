const utils = @import("../../helpers/utils.zig");
const graphics = @import("../../graphics/engine.zig");
const ent = @import("../../entities/entities.zig");
const std = @import("std");

pub const Button = struct {
    elemtype: []const u8,
    object: struct {
        text: []u8,
        width: u32,
        height: u32,
        pos: utils.Vec2,
    },
};

pub fn new(elem: Button, _: std.mem.Allocator) ent.Entity {
    const rect: graphics.Rect = .{ .h = @floatFromInt(elem.object.height), .w = @floatFromInt(elem.object.width), .x = elem.object.pos.x, .y = elem.object.pos.y };
    const entity = ent.Entity{ .has_text = true, .object = rect, .text = "test" };

    return entity;
}
