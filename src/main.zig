const board = @import("board.zig");
const Sq = board.Sq;
const movegen = @import("movegen.zig");
const position = @import("position.zig");

pub fn main() !void {
    initEngine();
    const pos = try position.fromFen("rnbqkb1r/pp1p1pPp/8/2p1pP2/1P1P4/3P3P/P1P1P3/RNBQKBNR w KQq e6 0 1");
    pos.print();
}

fn initEngine() void {
    movegen.initSliderAttackTables();
}
