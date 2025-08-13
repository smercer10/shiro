const std = @import("std");
const t = @import("types.zig");

pub fn main() void {
    var bb = t.Bitboard.fromU64(0);
    const sq = t.Square.a1;
    std.debug.print("Is {} set? {}\n", .{ sq, bb.isSet(sq) });
    std.debug.print("Least significant bit set: {?}\n", .{bb.getLsb()});
    bb.set(sq);
    std.debug.print("Is {} set? {}\n", .{ sq, bb.isSet(sq) });
    std.debug.print("Least significant bit set: {?}\n", .{bb.getLsb()});
    bb.clear(sq);
    std.debug.print("Is {} set? {}\n", .{ sq, bb.isSet(sq) });
    bb.set(sq);
    std.debug.print("Is {} set? {}\n", .{ sq, bb.isSet(sq) });
    std.debug.print("Least significant bit set: {?}\n", .{bb.popLsb()});
    std.debug.print("Is {} set? {}\n", .{ sq, bb.isSet(sq) });
    bb.set(sq);
    bb.set(.h8);
    bb.print();
}
