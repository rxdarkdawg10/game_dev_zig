const std = @import("std");
const utils = @import("../helpers/utils.zig");
const graphics = @import("../graphics/engine.zig");

const PLAYER_DIRECTION = enum { UP, DOWN, LEFT, RIGHT };

pub const Player = struct {
    t: bool,
    velocity: f32,
    speed: f32,
    gravity: f32,
    is_grounded: bool,
    jump_strength: f32,
    collision: struct { bool, graphics.Rect },
    rect: graphics.Rect,

    pub fn init() Player {
        return .{
            .t = true,
            .velocity = 0.0,
            .speed = 100,
            .gravity = 5,
            .is_grounded = false,
            .jump_strength = -5.0,
            .collision = .{ false, graphics.Rect{ .h = 0, .w = 0, .x = 0, .y = 0 } },
            .rect = .{ .x = 0.0, .y = 0.0, .w = 100.0, .h = 100.0 },
        };
    }

    pub fn update(self: *Player, eng: *graphics.Engine, entities: *std.ArrayList(graphics.Rect), dt: f32) void {
        for (entities.items) |entity| {
            self.collision = check_collision(self, entity);
        }
        // Player Movement
        if (eng.getKeyPress(graphics.KEYS.KEY_W)) {
            self.rect.y = self.rect.y - (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_D)) {
            self.rect.x = self.rect.x + (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_S)) {
            self.rect.y = self.rect.y + (self.speed * dt);
        }
        if (eng.getKeyPress(graphics.KEYS.KEY_A)) {
            self.rect.x = self.rect.x - (self.speed * dt);
        }

        if (eng.getKeyPress(graphics.KEYS.KEY_SPACE) and self.is_grounded) {
            self.rect.y = self.rect.y + self.jump_strength;
            self.is_grounded = false;
            self.velocity = self.jump_strength;
        }
    }

    pub fn draw(self: *Player, eng: *graphics.Engine, camera_pos: utils.Vec2, dt: f32) void {
        const rect: graphics.Rect = .{ .h = self.rect.h, .w = self.rect.w, .x = self.rect.x - camera_pos.x, .y = self.rect.y - camera_pos.y };
        _ = eng.setRenderDrawColor(graphics.Color{ .r = 100, .g = 33, .b = 43, .a = 255 });
        _ = eng.renderFillRect(rect);

        // Handle gravity
        if (self.collision.@"0") {
            self.velocity = 0.0;
            self.is_grounded = true;
        } else {
            self.velocity = self.velocity + (self.gravity * dt);
            self.rect.y = self.rect.y + (self.velocity);
        }
    }

    fn check_collision(self: *Player, entity: graphics.Rect) struct { bool, graphics.Rect } {
        // std.debug.print("ENTITY: {}\nPLAYER:{}\n\n", .{
        //     entity,

        //     self.rect,
        // });

        var checkRight = false;
        var checkBottom = false;
        var checkLeft = false;
        std.debug.print("Right: {}\n", .{@round(self.rect.x + self.rect.w)});
        if (@round(self.rect.x + self.rect.w) >= entity.x) {
            checkRight = true;
        }
        std.debug.print("Bottom: {}\n\n", .{@round(self.rect.y + self.rect.h)});
        if (@round(self.rect.y + self.rect.h) >= entity.y and @round(self.rect.y + self.rect.h) <= entity.y + entity.h) {
            checkBottom = true;
        }
        std.debug.print("Left: {}\n\n", .{self.rect.x});
        if (self.rect.x <= @round(entity.x + entity.w)) {
            checkLeft = true;
        }

        if (checkRight and checkBottom and checkLeft) {
            return .{ true, entity };
        }

        return .{ false, entity };
    }
};
