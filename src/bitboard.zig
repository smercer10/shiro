const std = @import("std");
const c = @import("common.zig");

pub fn isSet(bb: u64, sq: u8) bool {
    return (bb & (@as(u64, 1) << @intCast(sq))) != 0;
}

pub fn set(bb: *u64, sq: u8) void {
    bb.* |= (@as(u64, 1) << @intCast(sq));
}

pub fn clear(bb: *u64, sq: u8) void {
    bb.* &= ~(@as(u64, 1) << @intCast(sq));
}

pub fn getLsb(bb: u64) ?u8 {
    const lsb = @ctz(bb);
    if (lsb < @bitSizeOf(u64)) return lsb;
    return null;
}

pub fn popLsb(bb: *u64) ?u8 {
    const lsb = getLsb(bb.*);
    if (lsb) |sq| {
        clear(bb, sq);
        return sq;
    }
    return null;
}

pub fn print(bb: u64) void {
    for (0..c.num_ranks) |i| {
        const r = c.num_ranks - 1 - i;
        std.debug.print("{} | ", .{r + 1});
        for (0..c.num_files) |f| {
            const sq: u8 = @intCast(r * c.num_files + f);
            std.debug.print("{} ", .{@intFromBool(isSet(bb, sq))});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("  +----------------\n", .{});
    std.debug.print("    a b c d e f g h\n", .{});
    std.debug.print("\nBitboard: 0x{x}\n", .{bb});
}
