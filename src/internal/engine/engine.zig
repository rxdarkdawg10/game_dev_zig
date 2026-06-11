const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Engine = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,

    pub fn init() anyerror!Engine {
        // 1. Init Video
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
            std.log.err("SDL Init Failed: {s}", .{sdl.SDL_GetError()});
            return error.SdlInitFailed;
        }

        return Engine{};
    }

    pub fn quit() void {
        sdl.SDL_Quit();
    }
};

pub const Color = struct {
    pub fn init(r: u8, g: u8, b: u8, a: u8) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = r, .g = g, .b = b, .a = a };
    }
};
