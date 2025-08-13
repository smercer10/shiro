const std = @import("std");

pub const num_squares = 64;
pub const num_ranks = 8;
pub const num_files = 8;

// zig fmt: off
pub const Sq = enum(u8) {
    a1, b1, c1, d1, e1, f1, g1, h1,
    a2, b2, c2, d2, e2, f2, g2, h2,
    a3, b3, c3, d3, e3, f3, g3, h3,
    a4, b4, c4, d4, e4, f4, g4, h4,
    a5, b5, c5, d5, e5, f5, g5, h5,
    a6, b6, c6, d6, e6, f6, g6, h6,
    a7, b7, c7, d7, e7, f7, g7, h7,
    a8, b8, c8, d8, e8, f8, g8, h8, invalid
};
// zig fmt: on

pub fn isSet(bb: u64, sq: u8) bool {
    return (bb & (@as(u64, 1) << @intCast(sq))) != 0;
}

pub fn set(bb: *u64, sq: u8) void {
    bb.* |= (@as(u64, 1) << @intCast(sq));
}

pub fn clear(bb: *u64, sq: u8) void {
    bb.* &= ~(@as(u64, 1) << @intCast(sq));
}

pub fn getLsb(bb: u64) u8 {
    const lsb = @ctz(bb);
    if (lsb < num_squares) return lsb;
    return 0;
}

pub fn popLsb(bb: *u64) u8 {
    const lsb = getLsb(bb.*);
    clear(bb, lsb);
    return lsb;
}

pub fn print(bb: u64) void {
    for (0..num_ranks) |i| {
        const r = num_ranks - 1 - i;
        std.debug.print("{} | ", .{r + 1});
        for (0..num_files) |f| {
            const sq: u8 = @intCast(r * num_files + f);
            std.debug.print("{} ", .{@intFromBool(isSet(bb, sq))});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("  +----------------\n", .{});
    std.debug.print("    a b c d e f g h\n", .{});
    std.debug.print("\nBitboard: 0x{x}\n", .{bb});
}
