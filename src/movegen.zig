const std = @import("std");
const b = @import("bitboard.zig");
const c = @import("common.zig");
const p = @import("position.zig");

// zig fmt: off
const pawn_attacks = [c.num_sides][c.num_squares]u64{
    .{
        0x0000000000000200, 0x0000000000000500, 0x0000000000000a00, 0x0000000000001400,
        0x0000000000002800, 0x0000000000005000, 0x000000000000a000, 0x0000000000004000,
        0x0000000000020000, 0x0000000000050000, 0x00000000000a0000, 0x0000000000140000,
        0x0000000000280000, 0x0000000000500000, 0x0000000000a00000, 0x0000000000400000,
        0x0000000002000000, 0x0000000005000000, 0x000000000a000000, 0x0000000014000000,
        0x0000000028000000, 0x0000000050000000, 0x00000000a0000000, 0x0000000040000000,
        0x0000000200000000, 0x0000000500000000, 0x0000000a00000000, 0x0000001400000000,
        0x0000002800000000, 0x0000005000000000, 0x000000a000000000, 0x0000004000000000,
        0x0000020000000000, 0x0000050000000000, 0x00000a0000000000, 0x0000140000000000,
        0x0000280000000000, 0x0000500000000000, 0x0000a00000000000, 0x0000400000000000,
        0x0002000000000000, 0x0005000000000000, 0x000a000000000000, 0x0014000000000000,
        0x0028000000000000, 0x0050000000000000, 0x00a0000000000000, 0x0040000000000000,
        0x0200000000000000, 0x0500000000000000, 0x0a00000000000000, 0x1400000000000000,
        0x2800000000000000, 0x5000000000000000, 0xa000000000000000, 0x4000000000000000,
        0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
        0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000
    },
    .{
        0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
        0x0000000000000000, 0x0000000000000000, 0x0000000000000000, 0x0000000000000000,
        0x0000000000000002, 0x0000000000000005, 0x000000000000000a, 0x0000000000000014,
        0x0000000000000028, 0x0000000000000050, 0x00000000000000a0, 0x0000000000000040,
        0x0000000000000200, 0x0000000000000500, 0x0000000000000a00, 0x0000000000001400,
        0x0000000000002800, 0x0000000000005000, 0x000000000000a000, 0x0000000000004000,
        0x0000000000020000, 0x0000000000050000, 0x00000000000a0000, 0x0000000000140000,
        0x0000000000280000, 0x0000000000500000, 0x0000000000a00000, 0x0000000000400000,
        0x0000000002000000, 0x0000000005000000, 0x000000000a000000, 0x0000000014000000,
        0x0000000028000000, 0x0000000050000000, 0x00000000a0000000, 0x0000000040000000,
        0x0000000200000000, 0x0000000500000000, 0x0000000a00000000, 0x0000001400000000,
        0x0000002800000000, 0x0000005000000000, 0x000000a000000000, 0x0000004000000000,
        0x0000020000000000, 0x0000050000000000, 0x00000a0000000000, 0x0000140000000000,
        0x0000280000000000, 0x0000500000000000, 0x0000a00000000000, 0x0000400000000000,
        0x0002000000000000, 0x0005000000000000, 0x000a000000000000, 0x0014000000000000,
        0x0028000000000000, 0x0050000000000000, 0x00a0000000000000, 0x0040000000000000
    }
};

const knight_attacks = [c.num_squares]u64{
    0x0000000000020400, 0x0000000000050800, 0x00000000000a1100, 0x0000000000142200,
    0x0000000000284400, 0x0000000000508800, 0x0000000000a01000, 0x0000000000402000,
    0x0000000002040004, 0x0000000005080008, 0x000000000a110011, 0x0000000014220022,
    0x0000000028440044, 0x0000000050880088, 0x00000000a0100010, 0x0000000040200020,
    0x0000000204000402, 0x0000000508000805, 0x0000000a1100110a, 0x0000001422002214,
    0x0000002844004428, 0x0000005088008850, 0x000000a0100010a0, 0x0000004020002040,
    0x0000020400040200, 0x0000050800080500, 0x00000a1100110a00, 0x0000142200221400,
    0x0000284400442800, 0x0000508800885000, 0x0000a0100010a000, 0x0000402000204000,
    0x0002040004020000, 0x0005080008050000, 0x000a1100110a0000, 0x0014220022140000,
    0x0028440044280000, 0x0050880088500000, 0x00a0100010a00000, 0x0040200020400000,
    0x0204000402000000, 0x0508000805000000, 0x0a1100110a000000, 0x1422002214000000,
    0x2844004428000000, 0x5088008850000000, 0xa0100010a0000000, 0x4020002040000000,
    0x0400040200000000, 0x0800080500000000, 0x1100110a00000000, 0x2200221400000000,
    0x4400442800000000, 0x8800885000000000, 0x100010a000000000, 0x2000204000000000,
    0x0004020000000000, 0x0008050000000000, 0x00110a0000000000, 0x0022140000000000,
    0x0044280000000000, 0x0088500000000000, 0x0010a00000000000, 0x0020400000000000
};

const king_attacks = [c.num_squares]u64{
    0x0000000000000302, 0x0000000000000705, 0x0000000000000e0a, 0x0000000000001c14,
    0x0000000000003828, 0x0000000000007050, 0x000000000000e0a0, 0x000000000000c040,
    0x0000000000030203, 0x0000000000070507, 0x00000000000e0a0e, 0x00000000001c141c,
    0x0000000000382838, 0x0000000000705070, 0x0000000000e0a0e0, 0x0000000000c040c0,
    0x0000000003020300, 0x0000000007050700, 0x000000000e0a0e00, 0x000000001c141c00,
    0x0000000038283800, 0x0000000070507000, 0x00000000e0a0e000, 0x00000000c040c000,
    0x0000000302030000, 0x0000000705070000, 0x0000000e0a0e0000, 0x0000001c141c0000,
    0x0000003828380000, 0x0000007050700000, 0x000000e0a0e00000, 0x000000c040c00000,
    0x0000030203000000, 0x0000070507000000, 0x00000e0a0e000000, 0x00001c141c000000,
    0x0000382838000000, 0x0000705070000000, 0x0000e0a0e0000000, 0x0000c040c0000000,
    0x0003020300000000, 0x0007050700000000, 0x000e0a0e00000000, 0x001c141c00000000,
    0x0038283800000000, 0x0070507000000000, 0x00e0a0e000000000, 0x00c040c000000000,
    0x0302030000000000, 0x0705070000000000, 0x0e0a0e0000000000, 0x1c141c0000000000,
    0x3828380000000000, 0x7050700000000000, 0xe0a0e00000000000, 0xc040c00000000000,
    0x0203000000000000, 0x0507000000000000, 0x0a0e000000000000, 0x141c000000000000,
    0x2838000000000000, 0x5070000000000000, 0xa0e0000000000000, 0x40c0000000000000
};

const rook_masks = [c.num_squares]u64{
    0x000101010101017e, 0x000202020202027c, 0x000404040404047a, 0x0008080808080876,
    0x001010101010106e, 0x002020202020205e, 0x004040404040403e, 0x008080808080807e,
    0x0001010101017e00, 0x0002020202027c00, 0x0004040404047a00, 0x0008080808087600,
    0x0010101010106e00, 0x0020202020205e00, 0x0040404040403e00, 0x0080808080807e00,
    0x00010101017e0100, 0x00020202027c0200, 0x00040404047a0400, 0x0008080808760800,
    0x00101010106e1000, 0x00202020205e2000, 0x00404040403e4000, 0x00808080807e8000,
    0x000101017e010100, 0x000202027c020200, 0x000404047a040400, 0x0008080876080800,
    0x001010106e101000, 0x002020205e202000, 0x004040403e404000, 0x008080807e808000,
    0x0001017e01010100, 0x0002027c02020200, 0x0004047a04040400, 0x0008087608080800,
    0x0010106e10101000, 0x0020205e20202000, 0x0040403e40404000, 0x0080807e80808000,
    0x00017e0101010100, 0x00027c0202020200, 0x00047a0404040400, 0x0008760808080800,
    0x00106e1010101000, 0x00205e2020202000, 0x00403e4040404000, 0x00807e8080808000,
    0x007e010101010100, 0x007c020202020200, 0x007a040404040400, 0x0076080808080800,
    0x006e101010101000, 0x005e202020202000, 0x003e404040404000, 0x007e808080808000,
    0x7e01010101010100, 0x7c02020202020200, 0x7a04040404040400, 0x7608080808080800,
    0x6e10101010101000, 0x5e20202020202000, 0x3e40404040404000, 0x7e80808080808000
};

const bishop_masks = [c.num_squares]u64{
    0x0040201008040200, 0x0000402010080400, 0x0000004020100a00, 0x0000000040221400,
    0x0000000002442800, 0x0000000204085000, 0x0000020408102000, 0x0002040810204000,
    0x0020100804020000, 0x0040201008040000, 0x00004020100a0000, 0x0000004022140000,
    0x0000000244280000, 0x0000020408500000, 0x0002040810200000, 0x0004081020400000,
    0x0010080402000200, 0x0020100804000400, 0x004020100a000a00, 0x0000402214001400,
    0x0000024428002800, 0x0002040850005000, 0x0004081020002000, 0x0008102040004000,
    0x0008040200020400, 0x0010080400040800, 0x0020100a000a1000, 0x0040221400142200,
    0x0002442800284400, 0x0004085000500800, 0x0008102000201000, 0x0010204000402000,
    0x0004020002040800, 0x0008040004081000, 0x00100a000a102000, 0x0022140014224000,
    0x0044280028440200, 0x0008500050080400, 0x0010200020100800, 0x0020400040201000,
    0x0002000204081000, 0x0004000408102000, 0x000a000a10204000, 0x0014001422400000,
    0x0028002844020000, 0x0050005008040200, 0x0020002010080400, 0x0040004020100800,
    0x0000020408102000, 0x0000040810204000, 0x00000a1020400000, 0x0000142240000000,
    0x0000284402000000, 0x0000500804020000, 0x0000201008040200, 0x0000402010080400,
    0x0002040810204000, 0x0004081020400000, 0x000a102040000000, 0x0014224000000000,
    0x0028440200000000, 0x0050080402000000, 0x0020100804020000, 0x0040201008040200
};

const rook_magics = [c.num_squares]u64{
    0x0080001020400080, 0x0040001000200040, 0x0080081000200080, 0x0080040800100080,
    0x0080020400080080, 0x0080010200040080, 0x0080008001000200, 0x0080002040800100,
    0x0000800020400080, 0x0000400020005000, 0x0000801000200080, 0x0000800800100080,
    0x0000800400080080, 0x0000800200040080, 0x0000800100020080, 0x0000800040800100,
    0x0000208000400080, 0x0000404000201000, 0x0000808010002000, 0x0000808008001000,
    0x0000808004000800, 0x0000808002000400, 0x0000010100020004, 0x0000020000408104,
    0x0000208080004000, 0x0000200040005000, 0x0000100080200080, 0x0000080080100080,
    0x0000040080080080, 0x0000020080040080, 0x0000010080800200, 0x0000800080004100,
    0x0000204000800080, 0x0000200040401000, 0x0000100080802000, 0x0000080080801000,
    0x0000040080800800, 0x0000020080800400, 0x0000020001010004, 0x0000800040800100,
    0x0000204000808000, 0x0000200040008080, 0x0000100020008080, 0x0000080010008080,
    0x0000040008008080, 0x0000020004008080, 0x0000010002008080, 0x0000004081020004,
    0x0000204000800080, 0x0000200040008080, 0x0000100020008080, 0x0000080010008080,
    0x0000040008008080, 0x0000020004008080, 0x0000800100020080, 0x0000800041000080,
    0x00FFFCDDFCED714A, 0x007FFCDDFCED714A, 0x003FFFCDFFD88096, 0x0000040810002101,
    0x0001000204080011, 0x0001000204000801, 0x0001000082000401, 0x0001FFFAABFAD1A2
};

const bishop_magics = [c.num_squares]u64{
    0x0002020202020200, 0x0002020202020000, 0x0004010202000000, 0x0004040080000000,
    0x0001104000000000, 0x0000821040000000, 0x0000410410400000, 0x0000104104104000,
    0x0000040404040400, 0x0000020202020200, 0x0000040102020000, 0x0000040400800000,
    0x0000011040000000, 0x0000008210400000, 0x0000004104104000, 0x0000002082082000,
    0x0004000808080800, 0x0002000404040400, 0x0001000202020200, 0x0000800802004000,
    0x0000800400A00000, 0x0000200100884000, 0x0000400082082000, 0x0000200041041000,
    0x0002080010101000, 0x0001040008080800, 0x0000208004010400, 0x0000404004010200,
    0x0000840000802000, 0x0000404002011000, 0x0000808001041000, 0x0000404000820800,
    0x0001041000202000, 0x0000820800101000, 0x0000104400080800, 0x0000020080080080,
    0x0000404040040100, 0x0000808100020100, 0x0001010100020800, 0x0000808080010400,
    0x0000820820004000, 0x0000410410002000, 0x0000082088001000, 0x0000002011000800,
    0x0000080100400400, 0x0001010101000200, 0x0002020202000400, 0x0001010101000200,
    0x0000410410400000, 0x0000208208200000, 0x0000002084100000, 0x0000000020880000,
    0x0000001002020000, 0x0000040408020000, 0x0004040404040000, 0x0002020202020000,
    0x0000104104104000, 0x0000002082082000, 0x0000000020841000, 0x0000000000208800,
    0x0000000010020200, 0x0000000404080200, 0x0000040404040400, 0x0002020202020200
};

const rook_shifts = [c.num_squares]u8{
    52, 53, 53, 53, 53, 53, 53, 52,
    53, 54, 54, 54, 54, 54, 54, 53,
    53, 54, 54, 54, 54, 54, 54, 53,
    53, 54, 54, 54, 54, 54, 54, 53,
    53, 54, 54, 54, 54, 54, 54, 53,
    53, 54, 54, 54, 54, 54, 54, 53,
    53, 54, 54, 54, 54, 54, 54, 53,
    52, 53, 53, 53, 53, 53, 53, 52
};

const bishop_shifts = [c.num_squares]u8{
    58, 59, 59, 59, 59, 59, 59, 58,
    59, 59, 59, 59, 59, 59, 59, 59,
    59, 59, 57, 57, 57, 57, 59, 59,
    59, 59, 57, 55, 55, 57, 59, 59,
    59, 59, 57, 55, 55, 57, 59, 59,
    59, 59, 57, 57, 57, 57, 59, 59,
    59, 59, 59, 59, 59, 59, 59, 59,
    58, 59, 59, 59, 59, 59, 59, 58
};
// zig fmt: on

const Dir = struct {
    const n = 8;
    const s = -8;
    const e = 1;
    const w = -1;
    const ne = 9;
    const nw = 7;
    const se = -7;
    const sw = -9;
};

fn wrappedToAFile(sq: i8) bool {
    return (sq & (c.num_files - 1)) != 0;
}

fn wrappedToHFile(sq: i8) bool {
    return (sq & (c.num_files - 1)) != 7;
}

fn genRookAttacks(signed_sq: i8, occ: u64) u64 {
    var attacks: u64 = 0;

    var sq = signed_sq + Dir.n;
    while (sq < c.num_squares) : (sq += Dir.n) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.s;
    while (sq >= 0) : (sq += Dir.s) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.e;
    while ((sq < c.num_squares) and wrappedToAFile(sq)) : (sq += Dir.e) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.w;
    while ((sq >= 0) and wrappedToHFile(sq)) : (sq += Dir.w) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    return attacks;
}

fn genBishopAttacks(signed_sq: i8, occ: u64) u64 {
    var attacks: u64 = 0;

    var sq = signed_sq + Dir.ne;
    while ((sq < c.num_squares) and wrappedToAFile(sq)) : (sq += Dir.ne) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.nw;
    while ((sq < c.num_squares) and wrappedToHFile(sq)) : (sq += Dir.nw) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.se;
    while ((sq >= 0) and wrappedToAFile(sq)) : (sq += Dir.se) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    sq = signed_sq + Dir.sw;
    while ((sq >= 0) and wrappedToHFile(sq)) : (sq += Dir.sw) {
        b.set(&attacks, @intCast(sq));
        if (b.isSet(occ, @intCast(sq))) break;
    }

    return attacks;
}

fn idxToOcc(idx: u16, num_bits: u8, mask: u64) u64 {
    var mut_mask = mask;
    var occ: u64 = 0;
    var bit: u8 = 0;
    while (bit < num_bits) : (bit += 1) {
        const sq = b.popLsb(&mut_mask) orelse unreachable;
        if ((idx >> @intCast(bit)) & 1 != 0) b.set(&occ, sq);
    }
    return occ;
}

fn initSliderAttackTable(attacks_table: anytype, masks: [c.num_squares]u64, magics: [c.num_squares]u64, shifts: [c.num_squares]u8, genAttacksFn: fn (i8, u64) u64) void {
    for (0..c.num_squares) |sq| {
        const shift = shifts[sq];
        const num_bits = c.num_squares - shift;
        const max_idx = @as(u16, 1) << @intCast(num_bits);
        var idx: u16 = 0;
        while (idx < max_idx) : (idx += 1) {
            const occ = idxToOcc(idx, num_bits, masks[sq]);
            attacks_table[sq][(occ *% magics[sq]) >> @intCast(shift)] = genAttacksFn(@intCast(sq), occ);
        }
    }
}

const max_rook_occs = 4096;
var rook_attacks: [c.num_squares][max_rook_occs]u64 = undefined;

const max_bishop_occs = 512;
var bishop_attacks: [c.num_squares][max_bishop_occs]u64 = undefined;

pub fn initSliderAttackTables() void {
    initSliderAttackTable(&rook_attacks, rook_masks, rook_magics, rook_shifts, genRookAttacks);
    initSliderAttackTable(&bishop_attacks, bishop_masks, bishop_magics, bishop_shifts, genBishopAttacks);
}

pub fn getRookAttacks(sq: u8, occ: u64) u64 {
    const sq_idx: u6 = @intCast(sq);
    var mut_occ = occ;
    mut_occ &= rook_masks[sq_idx];
    mut_occ *%= rook_magics[sq_idx];
    mut_occ >>= @intCast(rook_shifts[sq_idx]);
    return rook_attacks[sq_idx][mut_occ];
}

pub fn getBishopAttacks(sq: u8, occ: u64) u64 {
    const sq_idx: u6 = @intCast(sq);
    var mut_occ = occ;
    mut_occ &= bishop_masks[sq_idx];
    mut_occ *%= bishop_magics[sq_idx];
    mut_occ >>= @intCast(bishop_shifts[sq_idx]);
    return bishop_attacks[sq_idx][mut_occ];
}

pub fn getQueenAttacks(sq: u8, occ: u64) u64 {
    return getRookAttacks(sq, occ) | getBishopAttacks(sq, occ);
}

const no_promo = 0;

pub const Move = struct {
    data: u32,

    const source_sq_mask = 0x3F; // Bits 0-5
    const target_sq_mask = 0xFC0; // Bits 6-11
    const moved_piece_mask = 0xF000; // Bits 12-15
    const promoted_piece_mask = 0xF0000; // Bits 16-19
    const capture_flag = 1 << 20;
    const double_push_flag = 1 << 21;
    const en_passant_flag = 1 << 22;
    const castling_flag = 1 << 23;

    const target_sq_shift = 6;
    const moved_piece_shift = 12;
    const promoted_piece_shift = 16;

    pub fn encode(source_sq: u8, target_sq: u8, moved_piece: u8, promoted_piece: u8, is_capture: bool, is_double_push: bool, is_en_passant: bool, is_castling: bool) Move {
        var data: u32 = 0;
        data |= @as(u32, source_sq) & source_sq_mask;
        data |= (@as(u32, target_sq) << target_sq_shift) & target_sq_mask;
        data |= (@as(u32, moved_piece) << moved_piece_shift) & moved_piece_mask;
        data |= (@as(u32, promoted_piece) << promoted_piece_shift) & promoted_piece_mask;
        if (is_capture) data |= capture_flag;
        if (is_double_push) data |= double_push_flag;
        if (is_en_passant) data |= en_passant_flag;
        if (is_castling) data |= castling_flag;
        return .{ .data = data };
    }

    fn sourceSq(self: Move) u8 {
        return @truncate(self.data & source_sq_mask);
    }

    fn targetSq(self: Move) u8 {
        return @truncate((self.data & target_sq_mask) >> target_sq_shift);
    }

    fn movedPiece(self: Move) u8 {
        return @truncate((self.data & moved_piece_mask) >> moved_piece_shift);
    }

    fn promotedPiece(self: Move) u8 {
        return @truncate((self.data & promoted_piece_mask) >> promoted_piece_shift);
    }

    fn isCapture(self: Move) bool {
        return (self.data & capture_flag) != 0;
    }

    fn isDoublePush(self: Move) bool {
        return (self.data & double_push_flag) != 0;
    }

    fn isEnPassant(self: Move) bool {
        return (self.data & en_passant_flag) != 0;
    }

    fn isCastling(self: Move) bool {
        return (self.data & castling_flag) != 0;
    }

    const promo_pieces = [c.num_pieces]u8{
        no_promo, 'n', 'b', 'r', 'q', no_promo,
        no_promo, 'n', 'b', 'r', 'q', no_promo,
    };

    // For stdout/UCI
    pub fn toString(self: Move, buf: []u8) []u8 {
        const source_sq = b.squares[self.sourceSq()];
        const target_sq = b.squares[self.targetSq()];
        const promo_piece = self.promotedPiece();
        if (promo_piece < promo_pieces.len and promo_pieces[promo_piece] != 0) {
            return std.fmt.bufPrint(buf, "{s}{s}{c}", .{ source_sq, target_sq, promo_pieces[promo_piece] }) catch buf[0..0];
        } else {
            return std.fmt.bufPrint(buf, "{s}{s}", .{ source_sq, target_sq }) catch buf[0..0];
        }
    }

    // For stderr/debugging
    pub fn format(self: Move, writer: anytype) !void {
        try writer.writeAll(c.squares[self.sourceSq()]);
        try writer.writeAll(c.squares[self.targetSq()]);
        const promo_piece = self.promotedPiece();
        if (promo_piece < promo_pieces.len and promo_pieces[promo_piece] != 0) try writer.writeByte(promo_pieces[promo_piece]);
    }
};

const MoveFilter = enum { all, just_captures };

pub const MoveList = struct {
    moves: [max_moves]Move = undefined,
    count: u8 = 0,

    const max_moves = 256;

    pub fn add(self: *MoveList, mv: Move) void {
        self.moves[self.count] = mv;
        self.count += 1;
    }

    pub fn print(self: MoveList) void {
        for (self.moves[0..self.count], 1..) |mv, i| {
            const flags = [4]u8{
                if (mv.isCapture()) 'x' else '-',
                if (mv.isDoublePush()) 'd' else '-',
                if (mv.isEnPassant()) 'e' else '-',
                if (mv.isCastling()) 'c' else '-',
            };

            std.debug.print("{}: {f} {c} {s}\n", .{ i, mv, c.Piece.ascii_chars[mv.movedPiece()], &flags });
        }
        std.debug.print("\nTotal moves: {}\n", .{self.count});
    }
};

fn isSquareAttacked(pos: p.Position, sq: u8, attacking_side: c.Side) bool {
    const piece_offset: u8 = if (attacking_side == c.Side.white) 0 else 6;

    if (knight_attacks[sq] & pos.piece_bbs[@intFromEnum(c.Piece.wn) + piece_offset] != 0) return true;
    if (king_attacks[sq] & pos.piece_bbs[@intFromEnum(c.Piece.wk) + piece_offset] != 0) return true;
    if (pawn_attacks[@intFromEnum(attacking_side) ^ 1][sq] & pos.piece_bbs[@intFromEnum(c.Piece.wp) + piece_offset] != 0) return true;

    const bishop_attacks_bb = getBishopAttacks(sq, pos.occ_bbs[@intFromEnum(c.Side.both)]);
    if (bishop_attacks_bb & (pos.piece_bbs[@intFromEnum(c.Piece.wb) + piece_offset] | pos.piece_bbs[@intFromEnum(c.Piece.wq) + piece_offset]) != 0) return true;

    const rook_attacks_bb = getRookAttacks(sq, pos.occ_bbs[@intFromEnum(c.Side.both)]);
    if (rook_attacks_bb & (pos.piece_bbs[@intFromEnum(c.Piece.wr) + piece_offset] | pos.piece_bbs[@intFromEnum(c.Piece.wq) + piece_offset]) != 0) return true;

    return false;
}

fn addPawnPromoMoves(move_list: *MoveList, source_sq: u8, target_sq: u8, pawn_type: u8, is_capture: bool) void {
    const promo_pieces = [4]c.Piece{ c.Piece.wq, c.Piece.wr, c.Piece.wb, c.Piece.wn };
    for (promo_pieces) |promo_piece| {
        move_list.add(Move.encode(source_sq, target_sq, pawn_type, @intFromEnum(promo_piece) + pawn_type, is_capture, false, false, false));
    }
}

fn sqInLastRank(sq: u8, side: c.Side) bool {
    return if (side == c.Side.white) sq >= @intFromEnum(c.Square.a8) else sq <= @intFromEnum(c.Square.h1);
}

fn sqInLastTwoRanks(sq: u8, side: c.Side) bool {
    return if (side == c.Side.white) sq >= @intFromEnum(c.Square.a7) else sq <= @intFromEnum(c.Square.h2);
}

fn pawnHasntMoved(sq: u8, side: c.Side) bool {
    return sqInLastTwoRanks(sq, @enumFromInt(@intFromEnum(side) ^ 1));
}

fn addPawnMoves(pos: p.Position, move_list: *MoveList, pawn_type: u8) void {
    const forward_jump: i8 = if (pawn_type == @intFromEnum(c.Piece.wp)) Dir.n else Dir.s;

    var pawn_bb = pos.piece_bbs[pawn_type];
    while (b.popLsb(&pawn_bb)) |source_sq| {
        if (!sqInLastRank(source_sq, pos.active_side)) {
            const target_sq: u8 = @intCast(@as(i8, @intCast(source_sq)) + forward_jump);

            if (!b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], target_sq)) {
                if (sqInLastRank(target_sq, pos.active_side)) {
                    addPawnPromoMoves(move_list, source_sq, target_sq, pawn_type, false);
                } else {
                    move_list.add(Move.encode(source_sq, target_sq, pawn_type, no_promo, false, false, false, false));
                }

                const double_push_target = @as(u8, @intCast(@as(i8, @intCast(target_sq)) + forward_jump));
                if (pawnHasntMoved(source_sq, pos.active_side) and
                    !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], double_push_target))
                {
                    move_list.add(Move.encode(source_sq, double_push_target, pawn_type, no_promo, false, true, false, false));
                }
            }
        }

        var attacks = pawn_attacks[@intFromEnum(pos.active_side)][source_sq] & pos.occ_bbs[(@intFromEnum(pos.active_side) ^ 1)];
        while (b.popLsb(&attacks)) |target_sq| {
            if (sqInLastRank(target_sq, pos.active_side)) {
                addPawnPromoMoves(move_list, source_sq, target_sq, pawn_type, true);
            } else {
                move_list.add(Move.encode(source_sq, target_sq, pawn_type, no_promo, true, false, false, false));
            }
        }

        if (pos.ep_sq) |ep_sq| {
            if (pawn_attacks[@intFromEnum(pos.active_side)][source_sq] & (@as(u64, 1) << @intCast(ep_sq)) != 0) {
                move_list.add(Move.encode(source_sq, ep_sq, pawn_type, no_promo, true, false, true, false));
            }
        }
    }
}

fn addCastlingMoves(pos: p.Position, move_list: *MoveList) void {
    if (pos.active_side == c.Side.white) {
        if (((pos.castling_rights & @intFromEnum(c.CastlingRight.wks)) != 0) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.f1)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.g1)) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.e1), c.Side.black) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.f1), c.Side.black))
        {
            move_list.add(Move.encode(@intFromEnum(c.Square.e1), @intFromEnum(c.Square.g1), @intFromEnum(c.Piece.wk), no_promo, false, false, false, true));
        }

        if (((pos.castling_rights & @intFromEnum(c.CastlingRight.wqs)) != 0) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.d1)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.c1)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.b1)) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.e1), c.Side.black) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.d1), c.Side.black))
        {
            move_list.add(Move.encode(@intFromEnum(c.Square.e1), @intFromEnum(c.Square.c1), @intFromEnum(c.Piece.wk), no_promo, false, false, false, true));
        }
    } else {
        if (((pos.castling_rights & @intFromEnum(c.CastlingRight.bks)) != 0) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.f8)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.g8)) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.e8), c.Side.white) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.f8), c.Side.white))
        {
            move_list.add(Move.encode(@intFromEnum(c.Square.e8), @intFromEnum(c.Square.g8), @intFromEnum(c.Piece.bk), no_promo, false, false, false, true));
        }

        if (((pos.castling_rights & @intFromEnum(c.CastlingRight.bqs)) != 0) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.d8)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.c8)) and
            !b.isSet(pos.occ_bbs[@intFromEnum(c.Side.both)], @intFromEnum(c.Square.b8)) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.e8), c.Side.white) and
            !isSquareAttacked(pos, @intFromEnum(c.Square.d8), c.Side.white))
        {
            move_list.add(Move.encode(@intFromEnum(c.Square.e8), @intFromEnum(c.Square.c8), @intFromEnum(c.Piece.bk), no_promo, false, false, false, true));
        }
    }
}

fn addGenericPieceMoves(pos: p.Position, move_list: *MoveList, attacks_func: fn (u8, u64) u64, piece_type: u8) void {
    var pieces = pos.piece_bbs[piece_type];
    while (b.popLsb(&pieces)) |source_sq| {
        var attacks = attacks_func(source_sq, pos.occ_bbs[@intFromEnum(c.Side.both)]) & ~pos.occ_bbs[@intFromEnum(pos.active_side)];
        while (b.popLsb(&attacks)) |target_sq| {
            const is_capture = b.isSet(pos.occ_bbs[@intFromEnum(pos.active_side) ^ 1], target_sq);
            move_list.add(Move.encode(source_sq, target_sq, piece_type, no_promo, is_capture, false, false, false));
        }
    }
}

fn getKnightAttacks(sq: u8, _: u64) u64 {
    return knight_attacks[sq];
}

fn getKingAttacks(sq: u8, _: u64) u64 {
    return king_attacks[sq];
}

pub fn genPseudoLegalMoves(pos: p.Position, move_list: *MoveList) void {
    move_list.count = 0;

    const piece_offset: u8 = if (pos.active_side == c.Side.white) 0 else 6;

    addPawnMoves(pos, move_list, @intFromEnum(c.Piece.wp) + piece_offset);
    addCastlingMoves(pos, move_list);
    addGenericPieceMoves(pos, move_list, getKnightAttacks, @intFromEnum(c.Piece.wn) + piece_offset);
    addGenericPieceMoves(pos, move_list, getBishopAttacks, @intFromEnum(c.Piece.wb) + piece_offset);
    addGenericPieceMoves(pos, move_list, getRookAttacks, @intFromEnum(c.Piece.wr) + piece_offset);
    addGenericPieceMoves(pos, move_list, getQueenAttacks, @intFromEnum(c.Piece.wq) + piece_offset);
    addGenericPieceMoves(pos, move_list, getKingAttacks, @intFromEnum(c.Piece.wk) + piece_offset);
}
