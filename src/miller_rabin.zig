//! Miller-Rabin primality test, returns a false positive with negligble probability.

const std = @import("std");
const utils = @import("utils.zig");
const testing = std.testing;

pub fn millerRabinTest(comptime T: type, n: T, rounds: usize, rand: std.rand.Random) bool {
    utils.assertIntegerType(T);

    if (n == 2) return true;
    if (@mod(n, 2) == 0 or n < 0) return false;

    var s: T = 0;
    var d: T = n - 1;
    while (@mod(d, 2) == 0) {
        d = @divExact(d, 2);
        s += 1;
    }

    var y: T = 0;
    var a: T = 0;
    var iter: usize = 0;
    while (iter < rounds) : (iter += 1) {
        a = rand.intRangeAtMost(T, 2, n - 1);
        var x = powermod(T, a, d, n);

        while (s > 0) : (s -= 1) {
            y = powermod(T, x, 2, n);
            if (y == 1 and x != 1 and x != n - 1) {
                return false;
            }

            x = y;
        }

        if (y != 1) {
            return false;
        }
    }

    return true;
}

/// Memory efficient modular exponentiation.
/// Computes `b^e mod n`.
fn powermod(comptime T: type, b: T, e: T, n: T) T {
    if (n == 1) {
        return n;
    }

    var c: T = 1;
    var e_prime: T = 0;
    while (e_prime < e) : (e_prime += 1) {
        c = @mod(c * b, n);
    }

    return c;
}

test "test_first_10000_primes_with_miller_rabin" {
    var prng = std.rand.DefaultPrng.init(42);
    const rand = prng.random();

    const primes = try utils.load10000Primes(u64);
    for (primes) |prime| {
        try testing.expectEqual(true, millerRabinTest(u64, prime, 5, rand));
    }
}
