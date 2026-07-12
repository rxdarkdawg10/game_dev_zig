const std = @import("std");
const sdl = @import("../graphics/sdl.zig").c;

pub const Vec2 = struct {
    x: f32,
    y: f32,

    pub fn init(x: f32, y: f32) Vec2 {
        return .{ .x = x, .y = y };
    }
};

pub const Mat2 = struct {
    tl: i32,
    tr: i32,
    bl: i32,
    br: i32,
};
