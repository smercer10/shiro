const std = @import("std");

const board = @import("board.zig");
const Sq = board.Sq;

const Side = enum(u8) {
    white,
    black,
    both,

    fn fromChar(c: u8) ?Side {
        return switch (c) {
            'w' => .white,
            'b' => .black,
            else => null,
        };
    }

    const count = 3;
};

const Piece = enum(u8) {
    // zig fmt: off
    wp, wn, wb, wr, wq, wk, 
    bp, bn, bb, br, bq, bk,

    fn fromChar(c: u8) ?Piece {
        return switch (c) {
            'P' => .wp, 'N' => .wn, 'B' => .wb, 'R' => .wr, 'Q' => .wq, 'K' => .wk,
            'p' => .bp, 'n' => .bn, 'b' => .bb, 'r' => .br, 'q' => .bq, 'k' => .bk,
            else => null
        };
    }
    // zig fmt: on

    const ascii_chars = "PNBRQKpnbrqk";

    fn toChar(self: Piece) u8 {
        return ascii_chars[@intFromEnum(self)];
    }

    fn side(self: Piece) Side {
        return switch (self) {
            .wp, .wn, .wb, .wr, .wq, .wk => Side.white,
            .bp, .bn, .bb, .br, .bq, .bk => Side.black,
        };
    }

    const count = 12;
};

const CastlingRight = enum(u8) { wks = 0b0001, wqs = 0b0010, bks = 0b0100, bqs = 0b1000 };

const State = struct {
    piece_bbs: [Piece.count]u64 = [_]u64{0} ** Piece.count,
    occ_bbs: [Side.count]u64 = [_]u64{0} ** Side.count,
    zobrist_hash: u64 = 0,
    fullmove_num: u16 = 1,
    halfmove_clock: u8 = 0,
    active_side: Side = .white,
    ep_sq: ?u8 = null,
    castling_rights: u8 = 0,

    fn pieceAt(self: State, sq: u8) ?Piece {
        for (self.piece_bbs, 0..) |bb, piece_idx| if (board.isSet(bb, sq)) return @enumFromInt(piece_idx);
        return null;
    }

    fn setPiece(self: *State, piece: Piece, sq: u8) void {
        const piece_idx = @intFromEnum(piece);
        board.set(&self.piece_bbs[piece_idx], sq);
        board.set(&self.occ_bbs[@intFromEnum(piece.side())], sq);
        board.set(&self.occ_bbs[@intFromEnum(Side.both)], sq);
    }

    pub fn print(self: State) void {
        for (0..board.num_ranks) |i| {
            const r = board.num_ranks - 1 - i;
            std.debug.print("{} | ", .{r + 1});
            for (0..board.num_files) |f| {
                const sq: u8 = @intCast(r * board.num_files + f);
                const piece_char = if (self.pieceAt(sq)) |piece| piece.toChar() else '.';
                std.debug.print("{c} ", .{piece_char});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("  +----------------\n", .{});
        std.debug.print("    a b c d e f g h\n", .{});

        std.debug.print("\nZobrist Hash: 0x{x}\n", .{self.zobrist_hash});
        std.debug.print("Fullmove Number: {}\n", .{self.fullmove_num});
        std.debug.print("Halfmove Clock: {}\n", .{self.halfmove_clock});
        std.debug.print("Active Side: {}\n", .{self.active_side});
        std.debug.print("Castling Rights: {s}{s}{s}{s}\n", .{
            if ((self.castling_rights & @intFromEnum(CastlingRight.wks)) != 0) "K" else "-",
            if ((self.castling_rights & @intFromEnum(CastlingRight.wqs)) != 0) "Q" else "-",
            if ((self.castling_rights & @intFromEnum(CastlingRight.bks)) != 0) "k" else "-",
            if ((self.castling_rights & @intFromEnum(CastlingRight.bqs)) != 0) "q" else "-",
        });
        std.debug.print("En Passant Square: {s}\n", .{if (self.ep_sq) |sq| board.squares[sq] else "-"});
    }
};

fn parseSquare(str: []const u8) ?u8 {
    if (str.len < 2) return null;
    if (str[0] < 'a' or str[0] > 'h' or str[1] < '1' or str[1] > '8') return null;
    return ((str[1] - '1') * board.num_files) + (str[0] - 'a');
}

pub fn fromFen(fen: []const u8) !State {
    var state = State{};
    var parts = std.mem.splitSequence(u8, fen, " ");

    const piece_placement_str = parts.next() orelse return error.InvalidFen;
    var rank: u8 = 7;
    var file: u8 = 0;
    for (piece_placement_str) |c| {
        switch (c) {
            '/' => {
                rank -= 1;
                file = 0;
            },
            '1'...'8' => file += c - '0',
            else => {
                const piece = Piece.fromChar(c) orelse return error.InvalidFen;
                state.setPiece(piece, rank * board.num_files + file);
                file += 1;
            },
        }
    }

    const active_side_str = parts.next() orelse return error.InvalidFen;
    state.active_side = Side.fromChar(active_side_str[0]) orelse return error.InvalidFen;

    const castling_rights_str = parts.next() orelse return error.InvalidFen;
    if (!std.mem.eql(u8, castling_rights_str, "-")) {
        for (castling_rights_str) |c| {
            state.castling_rights |= @intFromEnum(switch (c) {
                'K' => CastlingRight.wks,
                'Q' => CastlingRight.wqs,
                'k' => CastlingRight.bks,
                'q' => CastlingRight.bqs,
                else => return error.InvalidFen,
            });
        }
    }

    const ep_sq_str = parts.next() orelse return error.InvalidFen;
    state.ep_sq = parseSquare(ep_sq_str); // If there is no en passant square this will return null anyway

    if (parts.next()) |halfmove_clock_str| state.halfmove_clock = std.fmt.parseInt(u8, halfmove_clock_str, 10) catch 0;
    if (parts.next()) |fullmove_num_str| state.fullmove_num = std.fmt.parseInt(u16, fullmove_num_str, 10) catch 1;

    return state;
}
