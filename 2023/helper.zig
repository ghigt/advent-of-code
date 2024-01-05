const std = @import("std");

pub fn printBenchmark(cb: anytype, input: []const u8) void {
    const before = std.time.microTimestamp();
    const result = cb(input);
    const after = std.time.microTimestamp();

    const diff = switch (after - before) {
        0...999 => |r| .{ result, r, "µs" },
        1000...999999 => |r| .{ result, @divTrunc(r, 1000), "ms" },
        else => |r| .{ result, @divTrunc(r, 1000000), "s" },
    };

    std.debug.print("{d} in {d}{s}\n", diff);
}
