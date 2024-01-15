const std = @import("std");
const helper = @import("./helper.zig");

fn check1(input: []const u8, x: isize) bool {
    return if (x > 0 and x < input.len) {
        const ch = input[@intCast(x)];
        return ch != '\n' and !std.ascii.isDigit(ch) and ch != '.';
    } else false;
}

fn part1(input: []const u8) usize {
    const size: isize = std.mem.indexOfScalar(u8, input, '\n').? + 1;
    var result: usize = 0;
    var i: usize = 0;

    while (i < input.len) {
        if (std.ascii.isDigit(input[i])) {
            var curr: usize = i;
            var valid: bool = false;

            while (std.ascii.isDigit(input[curr])) : (curr += 1) {
                if (valid) continue;
                const icurr: isize = @intCast(curr);

                if (i == curr) {
                    if (check1(input, icurr - 1) or
                        check1(input, icurr - 1 - size) or
                        check1(input, icurr - 1 + size))
                    {
                        valid = true;
                    }
                }

                if (!valid and (check1(input, icurr - size) or
                    check1(input, icurr + size)))
                {
                    valid = true;
                }
            }
            const icurr: isize = @intCast(curr);

            if (!valid and (check1(input, icurr) or
                check1(input, icurr - size) or
                check1(input, icurr + size)))
            {
                valid = true;
            }

            result += if (valid)
                std.fmt.parseInt(u32, input[i..curr], 10) catch unreachable
            else
                0;

            i = curr + 1;
        } else {
            i += 1;
        }
    }

    return result;
}

pub fn main() !void {
    const input = @embedFile("./day3.txt");

    helper.printBenchmark(part1, input);
}
