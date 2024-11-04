//! Lucas-Lehmer mersenne primality test.

const std = @import("std");
const utils = @import("utils.zig");
const testing = std.testing;

/// A mersenne prime is any prime that satisfies `n = 2^p - 1`.
/// Note that `p` is the `p`:th mersenne number.
pub fn lucasLehmerTest(comptime T: type, p: T) bool {
    utils.assertIntegerType(T);

    const m = std.math.pow(T, 2, p) - 1;
    var s: T = 4;
    var iter: T = 0;
    while (iter < p - 2) : (iter += 1) {
        s = @mod((s * s) - 2, m);
    }

    return s == 0;
}

test "lucas_lehmer_test" {
    try testing.expectEqual(true, lucasLehmerTest(u8, 3));
    try testing.expectEqual(false, lucasLehmerTest(u32, 11));
    try testing.expectEqual(true, lucasLehmerTest(u64, 31));
}
