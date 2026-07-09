const std = @import("std");
const utils = @import("../helpers/utils.zig");
const graphics = @import("../graphics/engine.zig");

const PLAYER_DIRECTION = enum { UP, DOWN, LEFT, RIGHT };

pub const Player = struct {
    t: bool,
    pos: utils.Vec2,
    velocity: f32,
    speed: f32,
    gravity: f32,
    is_grounded: bool,
    jump_strength: f32,

    pub fn init() Player {
        return .{
            .t = true,
            .pos = .{ .x = 0.0, .y = 0.0 },
            .velocity = 0.0,
            .speed = 5,
            .gravity = 5,
            .is_grounded = false,
            .jump_strength = -5.0,
        };
    }

    pub fn update(self: *Player, eng: *graphics.Engine, dt: f32) void {
        if (eng.getKeyPress(graphics.KEYS.KEY_W)) {
            self.pos.y = self.pos.y - (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_D)) {
            self.pos.x = self.pos.x + (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_S)) {
            self.pos.y = self.pos.y + (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_A)) {
            self.pos.x = self.pos.x - (self.speed * dt);
        }

        if (eng.getKeyPress(graphics.KEYS.KEY_SPACE) and self.is_grounded) {
            self.is_grounded = false;
            self.velocity = self.jump_strength;
        }
    }

    pub fn draw(self: *Player, eng: *graphics.Engine, camera_pos: utils.Vec2, dt: f32) bool {
        const rect: graphics.Rect = .{ .h = 100.0, .w = 100.0, .x = self.pos.x - camera_pos.x, .y = self.pos.y - camera_pos.y };

        _ = eng.setRenderDrawColor(graphics.Color{ .r = 100, .g = 33, .b = 43, .a = 255 });
        _ = eng.renderFillRect(rect);

        self.velocity = self.velocity + (self.gravity * dt);
        self.pos.y = self.pos.y + self.velocity;

        if (self.pos.y >= 500.0) {
            self.pos.y = 500.0;
            self.velocity = 0.0;
            self.is_grounded = true;
        }
        return true;
    }
};
