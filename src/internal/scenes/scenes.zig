const std = @import("std");
const graphics = @import("../graphics/engine.zig");
const utils = @import("../helpers/utils.zig");
const ui = @import("../ui/ui.zig");
const ent = @import("../entities/entities.zig");

pub const SCENETYPES = enum {
    TITLE,
    WORLD1,
};

pub const Menu = struct {
    _t: SCENETYPES,
    entities: std.ArrayList(ent.Entity),
    allocator: std.mem.Allocator,

    pub fn init(scene_type: SCENETYPES, alloc: std.mem.Allocator, uiloader: *ui.UI) !Menu {
        var entities = std.ArrayList(ent.Entity).empty;
        // const rect: graphics.Rect = .{ .h = 50.0, .w = 800.0, .x = 0.0, .y = 300.0 };
        // _ = try entities.append(alloc, ent.Entity{ .object = rect, .has_text = false, .text = "" });

        _ = try uiloader.load("menu.json", &entities);

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
            const rect: graphics.Rect = .{ .h = entity.object.h, .w = entity.object.w, .x = entity.object.x, .y = entity.object.y };
            _ = eng.setRenderDrawColor(graphics.Color{ .r = 0, .g = 0, .b = 0, .a = 255 });
            _ = eng.renderFillRect(rect);
            if (entity.has_text) {
                // std.debug.print("{s}\n", .{entity.text});
                _ = try graphics.renderText(entity.text, eng.renderer, 32.0, graphics.Color{
                    .r = 255,
                    .g = 255,
                    .b = 255,
                    .a = 255,
                }, utils.Vec2{
                    .x = entity.object.x + (entity.object.w / 3),
                    .y = entity.object.y + (entity.object.h / 2),
                });
            }
        }
    }

    pub fn deinit(self: *Menu) void {
        for (self.entities.items) |item| {
            self.allocator.free(item.text);
        }
        self.entities.deinit(self.allocator);
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

    pub fn deinit(self: *World1) void {
        self.entities.deinit(self.allocator);
    }
};
