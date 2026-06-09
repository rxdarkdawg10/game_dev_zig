const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Color = struct {
    pub fn init(r: u8, g: u8, b: u8, a: u8) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = r, .g = g, .b = b, .a = a };
    }
};
