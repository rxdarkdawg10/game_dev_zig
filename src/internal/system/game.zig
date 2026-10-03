const std = @import("std");
const scenes = @import("../scenes/scenes.zig");
pub const GameState = struct {
    currentWorld: scenes.SCENETYPES,
    window_size: struct {
        width: u32,
        height: u32,
    },

    pub fn init() GameState {
        return .{
            .currentWorld = scenes.SCENETYPES.WORLD1,
            .window_size = undefined,
        };
    }
};
