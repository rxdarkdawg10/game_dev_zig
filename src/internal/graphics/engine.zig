const std = @import("std");
const utils = @import("../helpers/utils.zig");
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

    pub fn getKeyPress(self: *Engine, key: KEYS) bool {
        switch (key) {
            .KEY_W => {
                return self.keystate[sdl.SDL_SCANCODE_W];
            },
            .KEY_D => {
                return self.keystate[sdl.SDL_SCANCODE_D];
            },
            .KEY_S => {
                return self.keystate[sdl.SDL_SCANCODE_S];
            },
            .KEY_A => {
                return self.keystate[sdl.SDL_SCANCODE_A];
            },
            .KEY_SPACE => {
                return self.keystate[sdl.SDL_SCANCODE_SPACE];
            },
        }
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

    pub fn setRenderDrawColor(self: *Engine, color: Color) void {
        _ = sdl.SDL_SetRenderDrawColor(self.renderer, color.r, color.g, color.b, color.a);
    }

    pub fn renderFillRect(self: *Engine, rect: Rect) void {
        _ = sdl.SDL_RenderFillRect(self.renderer, &rect.to_sdl());
    }
};

pub const KEYS = enum {
    KEY_W,
    KEY_D,
    KEY_A,
    KEY_S,
    KEY_SPACE,
};

pub const Rect = struct {
    h: f32,
    w: f32,
    x: f32,
    y: f32,

    fn to_sdl(self: Rect) sdl.SDL_FRect {
        return sdl.SDL_FRect{ .h = self.h, .w = self.w, .x = self.x, .y = self.y };
    }
};

pub const Color = struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
    pub fn init(r: u8, g: u8, b: u8, a: u8) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = r, .g = g, .b = b, .a = a };
    }

    pub fn to_sdl(self: Color) sdl.SDL_Color {
        return sdl.SDL_Color{ .r = self.r, .g = self.g, .b = self.b, .a = self.a };
    }
};

pub fn renderText(text: []const u8, renderer: ?*sdl.SDL_Renderer, size: f32, color: Color, loc: utils.Vec2) anyerror!void {
    _ = sdl.TTF_Init();
    defer sdl.TTF_Quit();

    const font = sdl.TTF_OpenFont("assets/fonts/UbuntuMono-R.ttf", size);
    defer sdl.TTF_CloseFont(font);

    const surface = sdl.TTF_RenderText_Blended(font, text.ptr, 0, color.to_sdl()) orelse return error.TextureCreateFailed;
    defer sdl.SDL_DestroySurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
    defer sdl.SDL_DestroyTexture(texture);

    const dest_rect = sdl.SDL_FRect{
        .h = @floatFromInt(surface.*.h),
        .w = @floatFromInt(surface.*.w),
        .x = loc.x,
        .y = loc.y,
    };

    _ = sdl.SDL_RenderTexture(renderer, texture, null, &dest_rect);
}

pub fn renderSpritesheet(renderer: ?*sdl.SDL_Renderer, texture: ?*sdl.SDL_Texture, sprite: utils.Vec2, size: f32, sprite_loc: utils.Vec2) anyerror!void {
    const sprite_width: f32 = 32.0;
    const sprite_height: f32 = 32.0;

    const src_rect = sdl.SDL_FRect{
        .x = sprite.x,
        .y = sprite.y,
        .w = sprite_width,
        .h = sprite_height,
    };
    const dest_rect = sdl.SDL_FRect{
        .x = sprite_loc.x - sprite_width * size - 10.0,
        .y = sprite_loc.y,
        .w = sprite_width * size,
        .h = sprite_height * size,
    };

    _ = sdl.SDL_RenderTexture(renderer, texture, &src_rect, &dest_rect);
}
