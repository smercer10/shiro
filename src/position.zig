const std = @import("std");
const b = @import("bitboard.zig");
const c = @import("common.zig");

pub const Position = struct {
    piece_bbs: [c.num_pieces]u64 = std.mem.zeroes([c.num_pieces]u64),
    occ_bbs: [num_occ_bbs]u64 = std.mem.zeroes([num_occ_bbs]u64),
    zobrist_hash: u64 = 0,
    fullmove_num: u16 = 1,
    halfmove_clock: u8 = 0,
    active_side: c.Side = .white,
    ep_sq: ?u8 = null,
    castling_rights: u8 = 0,

    const num_occ_bbs = 3;

    fn pieceAt(self: Position, sq: u8) ?c.Piece {
        for (self.piece_bbs, 0..) |bb, piece_idx| if (b.isSet(bb, sq)) return @enumFromInt(piece_idx);
        return null;
    }

    fn setPiece(self: *Position, piece: c.Piece, sq: u8) void {
        const piece_idx = @intFromEnum(piece);
        b.set(&self.piece_bbs[piece_idx], sq);
        b.set(&self.occ_bbs[@intFromEnum(piece.side())], sq);
        b.set(&self.occ_bbs[@intFromEnum(c.Side.both)], sq);
    }

    pub fn print(self: Position) void {
        for (0..b.num_ranks) |i| {
            const r = b.num_ranks - 1 - i;
            std.debug.print("{} | ", .{r + 1});
            for (0..b.num_files) |f| {
                const sq: u8 = @intCast(r * b.num_files + f);
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
            if ((self.castling_rights & @intFromEnum(c.CastlingRight.wks)) != 0) "K" else "-",
            if ((self.castling_rights & @intFromEnum(c.CastlingRight.wqs)) != 0) "Q" else "-",
            if ((self.castling_rights & @intFromEnum(c.CastlingRight.bks)) != 0) "k" else "-",
            if ((self.castling_rights & @intFromEnum(c.CastlingRight.bqs)) != 0) "q" else "-",
        });
        std.debug.print("En Passant Square: {s}\n", .{if (self.ep_sq) |sq| b.squares[sq] else "-"});
    }
};

fn parseSquare(str: []const u8) ?u8 {
    if (str.len < 2) return null;
    if (str[0] < 'a' or str[0] > 'h' or str[1] < '1' or str[1] > '8') return null;
    return ((str[1] - '1') * c.num_files) + (str[0] - 'a');
}

pub fn fromFen(fen: []const u8) !Position {
    var pos = Position{};
    var parts = std.mem.splitSequence(u8, fen, " ");

    const piece_placement_str = parts.next() orelse return error.InvalidFen;
    var rank: u8 = 7;
    var file: u8 = 0;
    for (piece_placement_str) |ch| {
        switch (ch) {
            '/' => {
                rank -= 1;
                file = 0;
            },
            '1'...'8' => file += ch - '0',
            else => {
                const piece = c.Piece.fromChar(ch) orelse return error.InvalidFen;
                pos.setPiece(piece, rank * c.num_files + file);
                file += 1;
            },
        }
    }

    const active_side_str = parts.next() orelse return error.InvalidFen;
    pos.active_side = c.Side.fromChar(active_side_str[0]) orelse return error.InvalidFen;

    const castling_rights_str = parts.next() orelse return error.InvalidFen;
    if (!std.mem.eql(u8, castling_rights_str, "-")) {
        for (castling_rights_str) |ch| {
            pos.castling_rights |= @intFromEnum(switch (ch) {
                'K' => c.CastlingRight.wks,
                'Q' => c.CastlingRight.wqs,
                'k' => c.CastlingRight.bks,
                'q' => c.CastlingRight.bqs,
                else => return error.InvalidFen,
            });
        }
    }

    const ep_sq_str = parts.next() orelse return error.InvalidFen;
    pos.ep_sq = parseSquare(ep_sq_str); // If there is no en passant square this will correctly return null so upfront checks aren't needed

    if (parts.next()) |halfmove_clock_str| pos.halfmove_clock = std.fmt.parseInt(u8, halfmove_clock_str, 10) catch 0;
    if (parts.next()) |fullmove_num_str| pos.fullmove_num = std.fmt.parseInt(u16, fullmove_num_str, 10) catch 1;

    return pos;
}
