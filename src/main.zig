const std = @import("std");
const user = @import("internal/mobs/player.zig").Player;
const utils = @import("internal/helpers/utils.zig");
const Io = std.Io;

const sdl = @import("internal/graphics/sdl.zig").c;

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    // 1. Init Video
    if (!sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.log.err("SDL Init Failed: {s}", .{sdl.SDL_GetError()});
        return error.SdlInitFailed;
    }
    defer sdl.SDL_Quit();

    // 2. Create Window
    var window: ?*sdl.SDL_Window = null;
    var renderer: ?*sdl.SDL_Renderer = null;

    if (!sdl.SDL_CreateWindowAndRenderer("Zig + SDL3 C API", 800, 600, 0, &window, &renderer)) {
        std.log.err("Failed to create Window & Renderer: {s}", .{sdl.SDL_GetError()});
        return error.SdlWindowCreationFailed;
    }
    defer sdl.SDL_DestroyRenderer(renderer);
    defer sdl.SDL_DestroyWindow(window);

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
                    _ = sdl.SDL_SetWindowFullscreen(window, is_fullscreen);
                    _ = sdl.SDL_SyncWindow(window);
                }
                if (event.key.scancode == sdl.SDL_SCANCODE_ESCAPE) {
                    quit = true;
                }
            }
        }

        _ = sdl.SDL_SetRenderDrawColor(renderer, 33, 33, 43, 255);
        _ = sdl.SDL_RenderClear(renderer);

        _ = player.update(renderer);

        _ = try utils.renderText("Hello World", renderer, 32.0, sdl.SDL_Color{ .r = 255, .g = 255, .b = 255, .a = 255 }, utils.Vec2{ .x = 0.0, .y = 0.0 });
        _ = try utils.renderSpritesheet(renderer, utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        }, 4, utils.Vec2{
            .x = 150.0,
            .y = 50.0,
        });
        _ = sdl.SDL_RenderPresent(renderer);
    }
}
