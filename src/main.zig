const std = @import("std");
const user = @import("internal/mobs/player.zig").Player;
const utils = @import("internal/helpers/utils.zig");
const Io = std.Io;

const sdl = @import("internal/graphics/sdl.zig").c;
const engine = @import("internal/engine/engine.zig");

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    var eng = try engine.Engine.init();
    defer engine.Engine.quit();

    if (!sdl.SDL_CreateWindowAndRenderer("Zig + SDL3 C API", 800, 600, 0, &eng.window, &eng.renderer)) {
        std.log.err("Failed to create Window & Renderer: {s}", .{sdl.SDL_GetError()});
        return error.SdlWindowCreationFailed;
    }

    const surface = sdl.SDL_LoadPNG("assets/sprites/spritesheet.png") orelse return error.TextureCreateFailed;
    const texture = sdl.SDL_CreateTextureFromSurface(eng.renderer, surface);

    defer sdl.SDL_DestroySurface(surface);
    defer sdl.SDL_DestroyTexture(texture);
    defer sdl.SDL_DestroyRenderer(eng.renderer);
    defer sdl.SDL_DestroyWindow(eng.window);

    var player = user.init();
    // 3. Main Loop
    var quit = false;
    var is_fullscreen = false;
    while (!quit) {
        var event: sdl.SDL_Event = undefined;

        // Poll Events
        while (sdl.SDL_PollEvent(&event)) {
            if (event.type == sdl.SDL_EVENT_QUIT) {
                quit = true;
            }

            if (event.type == sdl.SDL_EVENT_KEY_UP) {
                if (event.key.scancode == sdl.SDL_SCANCODE_F11) {
                    is_fullscreen = !is_fullscreen;
                    _ = sdl.SDL_SetWindowFullscreen(eng.window, is_fullscreen);
                    _ = sdl.SDL_SyncWindow(eng.window);
                }
                if (event.key.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                    quit = true;
                }
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(eng.renderer, 33, 33, 43, 255);
        _ = sdl.SDL_RenderClear(eng.renderer);

        _ = player.update(eng.renderer);

        _ = try utils.renderText("Hello World", eng.renderer, 32.0, engine.Color.init(
            255,
            255,
            255,
            255,
        ), utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        });
        for (0..5) |i| {
            const val: i32 = @intCast(i);
            var x: f32 = @floatFromInt(val);
            x = x * 32.0;
            _ = try utils.renderSpritesheet(eng.renderer, texture, utils.Vec2{
                .x = x,
                .y = 0.0,
            }, 4, utils.Vec2{
                .x = 150.0 + (x * 4),
                .y = 50.0,
            });
        }
        _ = try utils.renderSpritesheet(eng.renderer, texture, utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        }, 4, utils.Vec2{
            .x = 150.0,
            .y = 50.0,
        });
        _ = sdl.SDL_RenderPresent(eng.renderer);
    }
}
