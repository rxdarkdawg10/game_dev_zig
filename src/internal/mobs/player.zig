const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;
const utils = @import("../helpers/utils.zig");

const PLAYER_DIRECTION = enum { UP, DOWN, LEFT, RIGHT };

pub const Player = struct {
    t: bool,
    pos: utils.Vec2,
    velocity: f32,

    pub fn init() Player {
        return .{ .t = true, .pos = .{ .x = 0.0, .y = 0.0 }, .velocity = 2.5 };
    }

    pub fn move(self: *Player, keys: [*]const bool) void {
        if (keys[sdl.SDL_SCANCODE_W] == true) {
            self.pos.y = self.pos.y - self.velocity;
        }

        if (keys[sdl.SDL_SCANCODE_S] == true) {
            self.pos.y = self.pos.y + self.velocity;
        }

        if (keys[sdl.SDL_SCANCODE_A] == true) {
            self.pos.x = self.pos.x - self.velocity;
        }

        if (keys[sdl.SDL_SCANCODE_D] == true) {
            self.pos.x = self.pos.x + self.velocity;
        }
    }

    pub fn update(self: *Player, renderer: ?*sdl.SDL_Renderer) bool {
        var rect: sdl.SDL_FRect = .{ .h = 100.0, .w = 100.0, .x = self.pos.x, .y = self.pos.y };

        _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 33, 43, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);
        return true;
    }
};
