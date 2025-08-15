const std = @import("std");
const m = @import("movegen.zig");
const c = @import("common.zig");

pub fn main() !void {
    initEngine();
    var move_list = m.MoveList{};
    const mv = m.Move.encode(@intFromEnum(c.Square.a1), @intFromEnum(c.Square.a2), @intFromEnum(c.Piece.wp), @intFromEnum(c.Piece.wq), true, true, false, true);
    move_list.add(mv);
    move_list.print();
}

fn initEngine() void {
    m.initSliderAttackTables();
}
