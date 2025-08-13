const board = @import("board.zig");
const Sq = board.Sq;
const movegen = @import("movegen.zig");

pub fn main() void {
    init();
    var occ: u64 = 0;
    board.set(&occ, @intFromEnum(Sq.e4));
    board.set(&occ, @intFromEnum(Sq.g7));
    board.set(&occ, @intFromEnum(Sq.b6));
    board.set(&occ, @intFromEnum(Sq.d3));
    board.print(occ);
    const attacks = movegen.getQueenAttacks(@intFromEnum(Sq.d4), occ);
    board.print(attacks);
}

fn init() void {
    movegen.initSliderAttackTables();
}
