const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Engine = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,
    texture: ?*sdl.SDL_Texture = null,

    pub fn init() anyerror!Engine {
        // 1. Init Video
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
            std.log.err("SDL Init Failed: {s}", .{sdl.SDL_GetError()});
            return error.SdlInitFailed;
        }

        return Engine{};
    }

    pub fn createWindowAndRenderer(self: *Engine) anyerror!void {
        if (!sdl.SDL_CreateWindowAndRenderer("Zig + SDL3 C API", 800, 600, 0, &self.window, &self.renderer)) {
            std.log.err("Failed to create Window & Renderer: {s}", .{sdl.SDL_GetError()});
            return error.SdlWindowCreationFailed;
        }
    }

    pub fn loadTexture(self: *Engine, file: []const u8) anyerror!void {
        const surface = sdl.SDL_LoadPNG(file.ptr) orelse return error.TextureCreateFailed;
        const texture = sdl.SDL_CreateTextureFromSurface(self.renderer, surface);
        self.texture = texture;
        defer sdl.SDL_DestroySurface(surface);
    }

    pub fn destroyTexture(self: *Engine) void {
        defer sdl.SDL_DestroyTexture(self.texture);
    }

    pub fn quit(self: *Engine) void {
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);

        sdl.SDL_Quit();
    }
};

pub const Color = struct {
    pub fn init(r: u8, g: u8, b: u8, a: u8) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = r, .g = g, .b = b, .a = a };
    }
};
