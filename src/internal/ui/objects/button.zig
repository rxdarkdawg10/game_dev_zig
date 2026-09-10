const utils = @import("../../helpers/utils.zig");
const graphics = @import("../graphics/engine.zig");

pub const Button = struct {
    elemtype: []const u8,
    object: struct {
        text: []const u8,
        width: u32,
        height: u32,
        pos: utils.Vec2,
    },

    fn draw(self: Button) graphics.Rect {
        const rect: graphics.Rect = .{ .h = self.object.height, .w = self.object.width, .x = self.object.pos.x, .y = self.object.pos.y };
        _ = rect;
    }
};
