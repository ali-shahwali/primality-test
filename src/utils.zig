const std = @import("std");
const testing = std.testing;

pub fn load10000Primes(comptime T: type) ![10000]T {
    const primes_txt = @embedFile("static/primes.txt");
    var iter = std.mem.splitScalar(u8, primes_txt, ',');

    var primes: [10000]T = undefined;
    var i: usize = 0;
    while (iter.next()) |item| : (i += 1) {
        const trimmed = std.mem.trim(u8, item, " \n\t\r");
        primes[i] = try std.fmt.parseUnsigned(T, trimmed, 10);
    }

    return primes;
}

pub fn assertIntegerType(comptime T: type) void {
    const ty_info = @typeInfo(T);
    switch (ty_info) {
        .int, .comptime_int => {},
        else => @compileError("invalid type: must be an integer"),
    }
}

test "load 10000 primes" {
    const primes = try load10000Primes(u32);

    try testing.expectEqual(2, primes[0]);
    try testing.expectEqual(104729, primes[primes.len - 1]);
}
