const std = @import("std");
const utils = @import("../helpers/utils.zig");
const graphics = @import("../graphics/engine.zig");

pub const Camera = struct {
    pos: utils.Vec2,
    width: f32,
    height: f32,
    lerpSpeed: f32,

    pub fn init(x: f32, y: f32, w: f32, h: f32) Camera {
        return .{
            .pos = .{ .x = x, .y = y },
            .width = w,
            .height = h,
            .lerpSpeed = 2,
        };
    }

    pub fn update(self: *Camera, player_pos: graphics.Rect, dt: f32) void {
        const targetX = player_pos.x - (800.0 / 2.0);
        const targetY = player_pos.y - (600.0 / 2.0);

        self.pos.x = self.lerp(self.pos.x, targetX, dt);
        self.pos.y = self.lerp(self.pos.y, targetY, dt);
    }

    fn lerp(self: *Camera, a: f32, b: f32, dt: f32) f32 {
        return a + (b - a) * (self.lerpSpeed * dt);
    }
};
