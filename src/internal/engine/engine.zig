const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Engine = struct {
    window: ?*sdl.SDL_Window = null,
    renderer: ?*sdl.SDL_Renderer = null,
    texture: ?*sdl.SDL_Texture = null,
    events: sdl.SDL_Event = undefined,
    keystate: [*c]const bool = undefined,
    quit_game: bool = false,
    is_fullscreen: bool = false,

    pub fn init() anyerror!Engine {
        // 1. Init Video
        if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
            std.log.err("SDL Init Failed: {s}", .{sdl.SDL_GetError()});
            return error.SdlInitFailed;
        }

        return Engine{};
    }

    pub fn createWindowAndRenderer(self: *Engine) anyerror!void {
        if (!sdl.SDL_CreateWindowAndRenderer("Game Dev", 800, 600, 0, &self.window, &self.renderer)) {
            std.log.err("Failed to create Window & Renderer: {s}", .{sdl.SDL_GetError()});
            return error.SdlWindowCreationFailed;
        }
    }

    pub fn getKeyboardState(self: *Engine) anyerror!void {
        var keys: c_int = 0;
        self.keystate = sdl.SDL_GetKeyboardState(&keys);
    }

    pub fn pollEvents(self: *Engine) bool {
        return sdl.SDL_PollEvent(&self.events);
    }

    pub fn handleEvents(self: *Engine) void {
        if (self.events.type == sdl.SDL_EVENT_QUIT) {
            self.quit_game = true;
        }

        if (self.events.type == sdl.SDL_EVENT_KEY_UP) {
            if (self.events.key.scancode == sdl.SDL_SCANCODE_F11) {
                self.is_fullscreen = !self.is_fullscreen;
                _ = sdl.SDL_SetWindowFullscreen(self.window, self.is_fullscreen);
                _ = sdl.SDL_SyncWindow(self.window);
            }
            if (self.events.key.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                self.quit_game = true;
            }
        }
    }

    pub fn setClearColor(self: *Engine, color: sdl.SDL_Color) void {
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, color.r, color.g, color.b, color.a);
        _ = sdl.SDL_RenderClear(self.renderer);
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

    pub fn renderScene(self: *Engine) void {
        _ = sdl.SDL_RenderPresent(self.renderer);
    }

    pub fn quit(self: *Engine) void {
        sdl.SDL_DestroyRenderer(self.renderer);
        sdl.SDL_DestroyWindow(self.window);

        sdl.SDL_Quit();
    }

    pub fn getTicks(self: *Engine) u64 {
        _ = self;

        return sdl.SDL_GetTicks();
    }

    pub fn getFPS(self: *Engine, fps: f64, alloc: std.mem.Allocator) anyerror![]const u8 {
        _ = self;
        const float_str = try std.fmt.allocPrint(alloc, "FPS: {d:.2}", .{fps});
        return float_str;
    }

    pub fn delayEngine(self: *Engine, delay: f64) void {
        _ = self;
        sdl.SDL_Delay(@intFromFloat(delay));
    }
};

pub const Color = struct {
    pub fn init(r: u8, g: u8, b: u8, a: u8) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = r, .g = g, .b = b, .a = a };
    }
};
