const std = @import("std");
const scenes = @import("../scenes/scenes.zig");
pub const GameState = struct {
    currentWorld: scenes.SCENETYPES,

    pub fn init() GameState {
        return .{
            .currentWorld = scenes.SCENETYPES.WORLD1,
        };
    }
};
