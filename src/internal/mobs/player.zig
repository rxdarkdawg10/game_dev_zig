const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Player = struct {
    t: bool,

    pub fn init() Player {
        return .{ .t = true };
    }

    pub fn update(self: *Player, renderer: ?*sdl.SDL_Renderer) bool {
        _ = self;

        var rect: sdl.SDL_FRect = .{ .h = 100.0, .w = 100.0, .x = 50.0, .y = 50.0 };

        _ = sdl.SDL_SetRenderDrawColor(renderer, 100, 33, 43, 255);
        _ = sdl.SDL_RenderFillRect(renderer, &rect);
        return true;
    }
};
