pub const num_ranks = 8;
pub const num_files = 8;
pub const num_squares = num_ranks * num_files;

// zig fmt: off
pub const Square = enum(u8) {
    a1, b1, c1, d1, e1, f1, g1, h1,
    a2, b2, c2, d2, e2, f2, g2, h2,
    a3, b3, c3, d3, e3, f3, g3, h3,
    a4, b4, c4, d4, e4, f4, g4, h4,
    a5, b5, c5, d5, e5, f5, g5, h5,
    a6, b6, c6, d6, e6, f6, g6, h6,
    a7, b7, c7, d7, e7, f7, g7, h7,
    a8, b8, c8, d8, e8, f8, g8, h8
};

pub const squares = [num_squares][]const u8 {
    "a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
    "a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
    "a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
    "a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
    "a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
    "a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
    "a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
    "a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8"
};
// zig fmt: on

pub const num_sides = 2; // Excludes both

pub const Side = enum(u8) {
    white,
    black,
    both, // Only considered for occupancy bitboards

    pub fn fromChar(ch: u8) ?Side {
        return switch (ch) {
            'w' => .white,
            'b' => .black,
            else => null,
        };
    }
};

pub const num_pieces = 12;

pub const Piece = enum(u8) {
    // zig fmt: off
    wp, wn, wb, wr, wq, wk, 
    bp, bn, bb, br, bq, bk,

    pub fn fromChar(ch: u8) ?Piece {
        return switch (ch) {
            'P' => .wp, 'N' => .wn, 'B' => .wb, 'R' => .wr, 'Q' => .wq, 'K' => .wk,
            'p' => .bp, 'n' => .bn, 'b' => .bb, 'r' => .br, 'q' => .bq, 'k' => .bk,
            else => null
        };
    }
    // zig fmt: on

    pub const ascii_chars = "PNBRQKpnbrqk";

    pub fn toChar(self: Piece) u8 {
        return ascii_chars[@intFromEnum(self)];
    }

    pub fn side(self: Piece) Side {
        return switch (self) {
            .wp, .wn, .wb, .wr, .wq, .wk => Side.white,
            .bp, .bn, .bb, .br, .bq, .bk => Side.black,
        };
    }
};

pub const CastlingRight = enum(u8) { wks = 0b0001, wqs = 0b0010, bks = 0b0100, bqs = 0b1000 };
