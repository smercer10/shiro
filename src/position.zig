const std = @import("std");

const board = @import("board.zig");

const num_pieces = 12;
const num_occupancies = 3;

const Side = enum(u8) { w, b, both };
const Piece = enum(u8) { wp, wn, wb, wr, wq, wk, bp, bn, bb, br, bq, bk, invalid };
const ascii_pieces = [num_pieces]u8{ 'P', 'N', 'B', 'R', 'Q', 'K', 'p', 'n', 'b', 'r', 'q', 'k' };
const Castling = enum(u8) { wks = 0b0001, wqs = 0b0010, bks = 0b0100, bqs = 0b1000 };

const Position = struct {
    pieces: [num_pieces]u64,
    occupancies: [num_occupancies]u64,
    hash: u64,
    fullmove: u16,
    halfmove: u8,
    side: u8,
    en_passant: u8,
    castling: u8,

    pub fn print(self: Position) void {
        for (0..board.num_ranks) |i| {
            const r = board.num_ranks - 1 - i;
            std.debug.print("{} | ", .{r + 1});
            for (0..board.num_files) |f| {
                const sq: u8 = @intCast(r * board.num_files + f);
                const piece = Piece.invalid;
                for (0..num_pieces) |p| {
                    if (board.isSet(self.pieces[p], sq)) {
                        piece = p;
                        break;
                    }
                }
                std.debug.print(" {} ", .{if (piece != Piece.invalid) std.ascii.pieces[piece] else '.'});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("  +----------------\n", .{});
        std.debug.print("    a b c d e f g h\n", .{});

        // TODO: Reformat these
        std.debug.print("Hash: {x}\n", .{self.hash});
        std.debug.print("Fullmove: {}\n", .{self.fullmove});
        std.debug.print("Halfmove: {}\n", .{self.halfmove});
        std.debug.print("Side: {}\n", .{self.side});
        std.debug.print("Castling: {}\n", .{self.castling});
        std.debug.print("En Passant: {}\n", .{self.en_passant});
    }
};
