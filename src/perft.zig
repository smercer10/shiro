const m = @import("movegen.zig");
const p = @import("position.zig");

fn perft(pos: *p.Position, depth: u8) u64 {
    if (depth == 0) return 1;

    var move_list = m.MoveList{};
    m.genPseudoLegalMoves(*pos, &move_list);

    var nodes: u64 = 0;
    for (move_list.moves) |mv| {
        const backup = pos.*;
        if (m.makeMove(pos, mv, m.MoveFilter.all)) nodes += perft(pos, depth - 1);
        pos.* = backup;
    }

    return nodes;
}
