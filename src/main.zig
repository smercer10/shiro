const std = @import("std");

const Sq = @import("board.zig").Sq;
const movegen = @import("movegen.zig");
const Piece = @import("position.zig").Piece;

pub fn main() !void {
    initEngine();
    var move_list = movegen.MoveList.init();
    const mv = movegen.Move.encode(@intFromEnum(Sq.a1), @intFromEnum(Sq.a2), @intFromEnum(Piece.wp), @intFromEnum(Piece.wq), true, true, false, true);
    move_list.add(mv);
    move_list.print();
}

fn initEngine() void {
    movegen.initSliderAttackTables();
}
