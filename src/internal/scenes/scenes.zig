const std = @import("std");
const graphics = @import("../graphics/engine.zig");
const utils = @import("../helpers/utils.zig");

pub const SCENETYPES = enum {
    TITLE,
    WORLD1,
};

pub const Menu = struct {
    _t: SCENETYPES,
    entities: std.ArrayList(graphics.Rect),
    allocator: std.mem.Allocator,

    pub fn init(scene_type: SCENETYPES, alloc: std.mem.Allocator) !Menu {
        var entities = std.ArrayList(graphics.Rect).empty;
        const rect: graphics.Rect = .{ .h = 50.0, .w = 800.0, .x = 0.0, .y = 300.0 };
        _ = try entities.append(alloc, rect);

        return Menu{
            ._t = scene_type,
            .entities = entities,
            .allocator = alloc,
        };
    }

    pub fn draw(self: *Menu, eng: *graphics.Engine, dt: f32) !void {
        _ = dt;

        _ = try graphics.renderText("The Game", eng.renderer, 32.0, graphics.Color{
            .r = 255,
            .g = 255,
            .b = 255,
            .a = 255,
        }, utils.Vec2{
            .x = eng.window_size.x / 2 - (100),
            .y = 0.0,
        });

        for (self.entities.items) |entity| {
            const rect: graphics.Rect = .{ .h = entity.h, .w = entity.w, .x = entity.x, .y = entity.y };
            _ = eng.setRenderDrawColor(graphics.Color{ .r = 0, .g = 0, .b = 0, .a = 255 });
            _ = eng.renderFillRect(rect);
        }
    }
};

pub const World1 = struct {
    _t: SCENETYPES,
    entities: std.ArrayList(graphics.Rect),
    allocator: std.mem.Allocator,

    pub fn init(scene_type: SCENETYPES, alloc: std.mem.Allocator) !World1 {
        // Generate World Objects
        var entities = std.ArrayList(graphics.Rect).empty;
        const rect: graphics.Rect = .{ .h = 50.0, .w = 800.0, .x = 0.0, .y = 300.0 };
        _ = try entities.append(alloc, rect);

        return World1{
            ._t = scene_type,
            .entities = entities,
            .allocator = alloc,
        };
    }

    pub fn update(self: *World1, eng: *graphics.Engine, dt: f32) void {
        _ = self;
        _ = eng;
        _ = dt;
    }

    pub fn draw(self: *World1, eng: *graphics.Engine, camera_pos: utils.Vec2, dt: f32) !void {
        _ = dt;

        for (self.entities.items) |entity| {
            const rect: graphics.Rect = .{ .h = entity.h, .w = entity.w, .x = entity.x - camera_pos.x, .y = entity.y - camera_pos.y };
            _ = eng.setRenderDrawColor(graphics.Color{ .r = 0, .g = 0, .b = 0, .a = 255 });
            _ = eng.renderFillRect(rect);
        }
    }
};
