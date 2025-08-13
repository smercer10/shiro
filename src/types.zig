const std = @import("std");
const c = @import("constants.zig");

// zig fmt: off
pub const Square = enum {
    a1, b1, c1, d1, e1, f1, g1, h1,
    a2, b2, c2, d2, e2, f2, g2, h2,
    a3, b3, c3, d3, e3, f3, g3, h3,
    a4, b4, c4, d4, e4, f4, g4, h4,
    a5, b5, c5, d5, e5, f5, g5, h5,
    a6, b6, c6, d6, e6, f6, g6, h6,
    a7, b7, c7, d7, e7, f7, g7, h7,
    a8, b8, c8, d8, e8, f8, g8, h8
};
// zig fmt: on

pub const Bitboard = struct {
    val: u64,

    pub fn fromU64(val: u64) Bitboard {
        return Bitboard{ .val = val };
    }

    pub fn isSet(self: Bitboard, sq: Square) bool {
        return (self.val & (@as(u64, 1) << @intFromEnum(sq))) != 0;
    }

    pub fn set(self: *Bitboard, sq: Square) void {
        self.val |= (@as(u64, 1) << @intFromEnum(sq));
    }

    pub fn clear(self: *Bitboard, sq: Square) void {
        self.val &= ~(@as(u64, 1) << @intFromEnum(sq));
    }

    pub fn getLsb(self: Bitboard) ?Square {
        const lsb = @ctz(self.val);
        if (lsb < c.num_squares) {
            return @enumFromInt(lsb);
        }
        return null;
    }

    pub fn popLsb(self: *Bitboard) ?Square {
        const lsb = getLsb(self.*) orelse return null;
        clear(self, lsb);
        return lsb;
    }

    pub fn print(self: Bitboard) void {
        for (0..c.num_ranks) |i| {
            const r = c.num_ranks - 1 - i;
            std.debug.print("{} | ", .{r + 1});
            for (0..c.num_files) |f| {
                const sq: Square = @enumFromInt(r * c.num_files + f);
                std.debug.print("{} ", .{@intFromBool(self.isSet(sq))});
            }
            std.debug.print("\n", .{});
        }
        std.debug.print("  +----------------\n", .{});
        std.debug.print("    a b c d e f g h\n", .{});
        std.debug.print("\nBitboard: 0x{x}\n", .{self.val});
    }
};
