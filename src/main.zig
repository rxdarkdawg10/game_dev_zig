const std = @import("std");
const user = @import("internal/mobs/player.zig").Player;
const utils = @import("internal/helpers/utils.zig");
const engine = @import("internal/engine/engine.zig");
const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    const arena: std.mem.Allocator = init.arena.allocator();

    const args = try init.minimal.args.toSlice(arena);
    for (args) |arg| {
        std.log.info("arg: {s}", .{arg});
    }

    var eng = try engine.Engine.init();
    defer eng.quit();

    _ = try eng.createWindowAndRenderer();

    _ = try eng.loadTexture("assets/sprites/spritesheet.png");
    defer eng.destroyTexture();

    var player = user.init();
    // 3. Main Loop

    while (!eng.quit_game) {
        _ = try eng.getKeyboardState();

        // Poll Events
        while (eng.pollEvents()) {
            eng.handleEvents();
        }

        player.move(eng.keystate);
        eng.setClearColor(engine.Color.init(33, 33, 43, 255));

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
            _ = try utils.renderSpritesheet(eng.renderer, eng.texture, utils.Vec2{
                .x = x,
                .y = 0.0,
            }, 4, utils.Vec2{
                .x = 150.0 + (x * 4),
                .y = 50.0,
            });
        }
        _ = try utils.renderSpritesheet(eng.renderer, eng.texture, utils.Vec2{
            .x = 0.0,
            .y = 0.0,
        }, 4, utils.Vec2{
            .x = 150.0,
            .y = 50.0,
        });
        eng.renderScene();
    }
}
