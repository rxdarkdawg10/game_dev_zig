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
