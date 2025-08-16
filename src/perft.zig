const std = @import("std");
const m = @import("movegen.zig");
const p = @import("position.zig");

fn perft(pos: *p.Position, depth: u8) u64 {
    if (depth == 0) return 1;

    var mv_list = m.MoveList{};
    m.genPseudoLegalMoves(pos.*, &mv_list);

    var nodes: u64 = 0;
    for (mv_list.moves[0..mv_list.count]) |mv| {
        const backup = pos.*;
        if (m.makeMove(pos, mv, m.MoveFilter.all)) nodes += perft(pos, depth - 1);
        pos.* = backup;
    }

    return nodes;
}

const PerftCase = struct {
    name: []const u8,
    fen: []const u8,
    exp_nodes: []const u64,
};

const ms_in_s = 1000;

fn runPerftCase(perft_case: PerftCase) !void {
    var pos = try p.fromFen(perft_case.fen);
    const start_time: f64 = @floatFromInt(std.time.milliTimestamp());
    for (perft_case.exp_nodes, 0..) |exp, depth| try std.testing.expectEqual(exp, perft(&pos, @intCast(depth)));
    const end_time: f64 = @floatFromInt(std.time.milliTimestamp());
    std.debug.print("perft: {s} took {}s up to depth {}\n", .{ perft_case.name, (end_time - start_time) / ms_in_s, perft_case.exp_nodes.len - 1 });
}

// Positions and expected results from https://www.chessprogramming.org/Perft_Results
const init_pos = PerftCase{ .name = "init_pos", .fen = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", .exp_nodes = &.{ 1, 20, 400, 8902, 197281, 4865609, 119060324 } };
const kiwipete = PerftCase{ .name = "kiwipete", .fen = "r3k2r/p1ppqpb1/bn2pnp1/3PN3/1p2P3/2N2Q1p/PPPBBPPP/R3K2R w KQkq -", .exp_nodes = &.{ 1, 48, 2039, 97862, 4085603, 193690690 } };
const pos3 = PerftCase{ .name = "pos3", .fen = "8/2p5/3p4/KP5r/1R3p1k/8/4P1P1/8 w - - 0 1", .exp_nodes = &.{ 1, 14, 191, 2812, 43238, 674624, 11030083, 178633661 } };
const pos4_original = PerftCase{ .name = "pos4_original", .fen = "r3k2r/Pppp1ppp/1b3nbN/nP6/BBP1P3/q4N2/Pp1P2PP/R2Q1RK1 w kq - 0 1", .exp_nodes = &.{ 1, 6, 264, 9467, 422333, 15833292, 706045033 } };
const pos4_mirrored = PerftCase{ .name = "pos4_mirrored", .fen = "r2q1rk1/pP1p2pp/Q4n2/bbp1p3/Np6/1B3NBn/pPPP1PPP/R3K2R b KQ - 0 1", .exp_nodes = &.{ 1, 6, 264, 9467, 422333, 15833292, 706045033 } };
const pos5 = PerftCase{ .name = "pos5", .fen = "rnbq1k1r/pp1Pbppp/2p5/8/2B5/8/PPP1NnPP/RNBQK2R w KQ - 1 8", .exp_nodes = &.{ 1, 44, 1486, 62379, 2103487, 89941194 } };
const pos6 = PerftCase{ .name = "pos6", .fen = "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10", .exp_nodes = &.{ 1, 46, 2079, 89890, 3894594, 164075551 } };

const perft_cases = &[_]PerftCase{
    init_pos,
    kiwipete,
    pos3,
    pos4_original,
    pos4_mirrored,
    pos5,
    pos6,
};

test "perft" {
    m.initSliderAttackTables();
    const start_time: f64 = @floatFromInt(std.time.milliTimestamp());
    for (perft_cases) |case| try runPerftCase(case);
    const end_time: f64 = @floatFromInt(std.time.milliTimestamp());
    std.debug.print("perft: took {}s in total\n", .{(end_time - start_time) / ms_in_s});
}
