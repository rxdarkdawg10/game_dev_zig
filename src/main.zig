const std = @import("std");
const user = @import("internal/mobs/player.zig").Player;
const utils = @import("internal/helpers/utils.zig");
const engine = @import("internal/engine/engine.zig");
const Io = std.Io;
const sdl = @import("internal/graphics/sdl.zig").c;

fn lerp(a: f32, b: f32, t: f32) f32 {
    return a + (b - a) * t;
}

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    var eng = try engine.Engine.init();
    defer eng.quit();

    const frameCap: f64 = 1000.0 / 60.0;
    var frameCount: f64 = 0.0;
    _ = try eng.createWindowAndRenderer();

    _ = try eng.loadTexture("assets/sprites/spritesheet.png");
    defer eng.destroyTexture();

    var player = user.init();
    var camera: sdl.SDL_FRect = .{ .x = 0.0, .y = 0.0, .w = 800.0, .h = 600.0 };
    const lerpSpeed: f32 = 0.05;
    // 3. Main Loop

    // Delta Time
    var lastTime: f64 = @floatFromInt(eng.getTicks());
    var deltaTime: f64 = 0.0;

    while (!eng.quit_game) {
        const currentTime: f64 = @floatFromInt(eng.getTicks());

        deltaTime = (currentTime - lastTime) / 1000.0;
        lastTime = currentTime;

        _ = try eng.getKeyboardState();

        // Poll Events
        while (eng.pollEvents()) {
            eng.handleEvents();
        }

        player.move(eng.keystate);
        eng.setClearColor(engine.Color.init(33, 33, 43, 255));

        const targetX = player.pos.x - (800.0 / 2.0);
        const targetY = player.pos.y - (600.0 / 2.0);

        camera.x = lerp(camera.x, targetX, lerpSpeed);
        camera.y = lerp(camera.y, targetY, lerpSpeed);

        _ = player.update(eng.renderer, camera);

        const fps = try eng.getFPS(1.0 / deltaTime, arena);
        _ = try utils.renderText(fps, eng.renderer, 32.0, engine.Color.init(
            255,
            255,
            255,
            255,
        ), utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        });

        const player_pos_str = try std.fmt.allocPrint(arena, "POS X: {d:.0} POS: Y: {d:.0}", .{ player.pos.x, player.pos.y });
        _ = try utils.renderText(player_pos_str, eng.renderer, 32.0, engine.Color.init(
            255,
            255,
            255,
            255,
        ), utils.Vec2{
            .x = 0.0,
            .y = 32.0,
        });

        // for (0..5) |i| {
        //     const val: i32 = @intCast(i);
        //     var x: f32 = @floatFromInt(val);
        //     x = x * 32.0;
        //     _ = try utils.renderSpritesheet(eng.renderer, eng.texture, utils.Vec2{
        //         .x = x,
        //         .y = 0.0,
        //     }, 4, utils.Vec2{
        //         .x = 150.0 + (x * 4),
        //         .y = 50.0,
        //     });
        // }
        _ = try utils.renderSpritesheet(eng.renderer, eng.texture, utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        }, 2, utils.Vec2{
            .x = 800.0 - 16.0,
            .y = 0.0,
        });

        var frameTimer = deltaTime * 1000.0;
        frameCount = frameCount + 1;
        if (frameTimer >= 1000.0) {
            frameCount = 0.0;
            frameTimer = 0.0;
        }

        var frameTicks: f64 = @floatFromInt(eng.getTicks());
        frameTicks = frameTicks - currentTime;
        if (frameTicks < frameCap) {
            eng.delayEngine(frameCap - frameTicks);
        }

        eng.renderScene();
    }
}
