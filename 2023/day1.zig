const std = @import("std");
const helper = @import("./helper.zig");

const State = union(enum) {
    empty,
    single_digit: usize,
    double_digit: struct { usize, usize },

    pub fn reset(self: *State) void {
        self.* = .empty;
    }

    pub fn update(self: *State, val: usize) void {
        self.* = switch (self.*) {
            .empty => .{ .single_digit = val },
            .single_digit => |a| .{ .double_digit = .{ a, val } },
            .double_digit => |a| .{ .double_digit = .{ a.@"0", val } },
        };
    }

    pub fn extract(self: State) usize {
        return switch (self) {
            .empty => unreachable,
            .single_digit => |a| a * 10 + a,
            .double_digit => |a| a.@"0" * 10 + a.@"1",
        };
    }
};

fn trebuchet_simple(input: []const u8) usize {
    var result: usize = 0;
    var state: State = .empty;

    for (input) |ch| {
        if (std.ascii.isDigit(ch)) {
            state.update(ch - '0');
        } else if (ch == '\n') {
            result += state.extract();
            state.reset();
        }
    }

    return result;
}

const words = [_][]const u8{
    "one", "two", "three", "four", "five", "six", "seven", "eight", "nine",
};

fn trebuchet_wordy(input: []const u8) usize {
    var result: usize = 0;
    var state: State = .empty;
    var idx: usize = 0;

    while (idx < input.len) : (idx += 1) {
        for (words, 0..) |word, i| {
            if (std.mem.startsWith(u8, input[idx..], word)) {
                state.update(i + 1);
                idx += word.len - 2;
                break;
            }
        } else {
            switch (input[idx]) {
                '0'...'9' => |ch| state.update(ch - '0'),
                '\n' => {
                    result += state.extract();
                    state.reset();
                },
                else => {},
            }
        }
    }

    return result;
}

pub fn main() void {
    const input = @embedFile("./day1.txt");

    helper.printBenchmark(trebuchet_simple, input);
    helper.printBenchmark(trebuchet_wordy, input);
}
