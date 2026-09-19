const std = @import("std");
const btntype = @import("objects/button.zig");
const ent = @import("../entities/entities.zig");

const Element = struct {
    elemtype: []const u8,
};

pub const UI = struct {
    io: std.Io,
    alloc: std.mem.Allocator,

    pub fn new(io: std.Io, alloc: std.mem.Allocator) UI {
        return .{ .io = io, .alloc = alloc };
    }

    pub fn load(self: UI, filename: []const u8, entities: *std.ArrayList(ent.Entity)) !void {
        var buffer: [1024]u8 = undefined;
        const file = try loadUIFromFile(filename, self.io, &buffer);

        const peak = try std.json.parseFromSlice(Element, self.alloc, file, .{ .ignore_unknown_fields = true });
        defer peak.deinit();

        if (std.mem.eql(u8, peak.value.elemtype, "button")) {
            const elem = try std.json.parseFromSlice(btntype.Button, self.alloc, file, .{ .ignore_unknown_fields = true });
            defer elem.deinit();
            const button: ent.Entity = btntype.new(.{ .elemtype = elem.value.elemtype, .object = .{
                .height = elem.value.object.height,
                .width = elem.value.object.width,
                .pos = elem.value.object.pos,
                .text = elem.value.object.text,
            } }, self.alloc);
            _ = try entities.append(self.alloc, button);
        }
    }
};

fn loadUIFromFile(file_name: []const u8, io: std.Io, buffer: []u8) ![]u8 {
    var dir = try std.Io.Dir.cwd().openDir(io, "./assets/uiconfig", .{});
    defer dir.close(io);

    const file = try dir.readFile(io, file_name, buffer);

    return file;
}
