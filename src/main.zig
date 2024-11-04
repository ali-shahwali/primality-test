const std = @import("std");
const primality_test = @import("primality-test");
const builtin = @import("builtin");

fn printUsage() noreturn {
    std.debug.print("Usage: \n\t primality-test <lucas-lehmer|miller-rabin> <integer>", .{});
    std.process.exit(1);
}

fn errorAndExit(err: anyerror) noreturn {
    std.debug.print("Error: {s}\n", .{@errorName(err)});
    printUsage();
}

const Algorithm = enum { miller_rabin, lucas_lehmer };

const Input = struct {
    number: u128,
    algorithm: Algorithm,

    const Self = @This();

    fn create(algorithm: []const u8, number: []const u8) !Self {
        if (!std.mem.eql(u8, algorithm, "lucas-lehmer") and
            !std.mem.eql(u8, algorithm, "miller-rabin"))
        {
            return error.InvalidAlgorithm;
        }

        var alg: Algorithm = undefined;
        if (std.mem.eql(u8, algorithm, "lucas-lehmer")) {
            alg = Algorithm.lucas_lehmer;
        } else {
            alg = Algorithm.miller_rabin;
        }

        const n = try std.fmt.parseUnsigned(u128, number, 10);

        return Self{
            .algorithm = alg,
            .number = n,
        };
    }

    fn isPrime(self: Self) bool {
        const t0 = std.time.microTimestamp();

        var is_prime = false;
        switch (self.algorithm) {
            .miller_rabin => {
                std.debug.print("Running 2 rounds of the Miller-Rabin primality test...\n", .{});
                var prng = std.rand.DefaultPrng.init(@intCast(std.time.milliTimestamp()));
                const rand = prng.random();
                is_prime = primality_test.millerRabinTest(u128, self.number, 2, rand);
            },
            .lucas_lehmer => {
                std.debug.print("Running the Lucas-Lehmer mersenne prime test...\n", .{});
                is_prime = primality_test.lucasLehmerTest(u128, self.number);
            },
        }

        const t = std.time.microTimestamp() - t0;
        std.debug.print("Test took {d}ms\n", .{t});

        return is_prime;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var iter = try std.process.argsWithAllocator(allocator);
    defer iter.deinit();
    _ = iter.skip();

    var args = std.ArrayList([]const u8).init(allocator);

    while (iter.next()) |arg| {
        try args.append(arg);
    }

    if (args.items.len != 2) {
        errorAndExit(error.InvalidArgs);
    }

    const input = Input.create(args.items[0], args.items[1]) catch |err| {
        errorAndExit(err);
    };

    if (input.isPrime()) {
        std.debug.print("{d} is a prime number according to {s} test", .{ input.number, @tagName(input.algorithm) });
    } else {
        std.debug.print("{d} is NOT a prime number according to {s} test", .{ input.number, @tagName(input.algorithm) });
    }
}
