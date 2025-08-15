const std = @import("std");
const m = @import("movegen.zig");
const c = @import("common.zig");
const p = @import("position.zig");

pub fn main() !void {
    initEngine();
    const pos = try p.fromFen("r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq - 0 1");
    var move_list = m.MoveList{};
    m.genPseudoLegalMoves(pos, &move_list);
    move_list.print();
}

fn initEngine() void {
    m.initSliderAttackTables();
}
