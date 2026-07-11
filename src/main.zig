const std = @import("std");
const user = @import("internal/mobs/player.zig").Player;
const cam = @import("internal/system/camera.zig").Camera;
const utils = @import("internal/helpers/utils.zig");
const engine = @import("internal/graphics/engine.zig");
const game = @import("internal/system/game.zig");
const scenes = @import("internal/scenes/scenes.zig");
const Io = std.Io;
const sdl = @import("internal/graphics/sdl.zig").c;

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
    const gameState = game.GameState.init();
    var player = user.init();
    var camera = cam.init(0.0, 0.0, 800.0, 600.0);
    var world1 = try scenes.World1.init(scenes.SCENETYPES.WORLD1, arena);

    _ = gameState;
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

        // Update Game Elements
        world1.update(&eng, @floatCast(deltaTime));
        player.update(&eng, &world1.entities, @floatCast(deltaTime));

        // Draw Game Elements
        eng.setClearColor(engine.Color.init(33, 33, 43, 255)); // <- Base Background Color
        _ = try world1.draw(&eng, camera.pos, @floatCast(deltaTime));
        _ = camera.update(player.pos, @floatCast(deltaTime));
        _ = player.draw(&eng, camera.pos, @floatCast(deltaTime));

        const fps = try eng.getFPS(1.0 / deltaTime, arena);
        _ = try engine.renderText(fps, eng.renderer, 32.0, engine.Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = 255,
        }, utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        });

        const player_pos_str = try std.fmt.allocPrint(arena, "POS X: {d:.0} POS: Y: {d:.0}, Collision: {}", .{ player.pos.x, player.pos.y, player.collision });
        _ = try engine.renderText(player_pos_str, eng.renderer, 32.0, engine.Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = 255,
        }, utils.Vec2{
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
        _ = try engine.renderSpritesheet(eng.renderer, eng.texture, utils.Vec2{
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
