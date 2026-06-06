const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }
};

pub fn renderText(text: []const u8, renderer: ?*sdl.SDL_Renderer, size: f32, color: sdl.SDL_Color, loc: Vec2) anyerror!void {
    _ = sdl.TTF_Init();
    defer sdl.TTF_Quit();

    const font = sdl.TTF_OpenFont("assets/fonts/UbuntuMono-R.ttf", size);
    defer sdl.TTF_CloseFont(font);

    const surface = sdl.TTF_RenderText_Blended(font, text.ptr, 0, color) orelse return error.TextureCreateFailed;
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

pub fn renderSpritesheet(renderer: ?*sdl.SDL_Renderer, sprite: Vec2, size: f32, sprite_loc: Vec2) anyerror!void {
    const surface = sdl.SDL_LoadPNG("assets/sprites/spritesheet.png") orelse return error.TextureCreateFailed;
    defer sdl.SDL_DestroySurface(surface);

    const texture = sdl.SDL_CreateTextureFromSurface(renderer, surface);
    defer sdl.SDL_DestroyTexture(texture);

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
