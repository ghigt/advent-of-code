const std = @import("std");
const helper = @import("./helper.zig");

const ColorName = enum { red, green, blue };
const colors = [_][]const u8{ "red", "green", "blue" };

fn cubeGame(input: []const u8) usize {
    var game_idx: usize = 1;
    var result: usize = 0;
    var i: usize = 0;
    var valid: bool = true;

    while (i < input.len) {
        const ch = input[i];

        if (ch == '\n') {
            result += if (valid) game_idx else 0;
            game_idx += 1;
            valid = true;
            i += 1;
            continue;
        } else if (!valid or ch == ' ' or ch == ';' or ch == ',') {
            i += 1;
            continue;
        } else if (std.mem.startsWith(u8, input[i..], "Game ")) {
            i += 6; // skip "Game 0"
            while (std.ascii.isDigit(input[i])) : (i += 1) {}
            i += 2; // skip ": "
            continue;
        }

        var end: usize = i;
        while (std.ascii.isDigit(input[end])) : (end += 1) {}

        const num = std.fmt.parseInt(u8, input[i..end], 10) catch unreachable;

        i = end + 1;
        for (colors) |color| {
            if (std.mem.startsWith(u8, input[i..], color)) {
                const name = std.meta.stringToEnum(ColorName, color).?;

                valid = switch (name) {
                    .red => num <= 12,
                    .green => num <= 13,
                    .blue => num <= 14,
                };

                i += color.len;
            }
        }
    }

    return result;
}

fn cubePower(input: []const u8) usize {
    var result: usize = 0;
    var i: usize = 0;

    var game: struct {
        red: usize = 0,
        green: usize = 0,
        blue: usize = 0,
    } = .{};

    while (i < input.len) {
        const ch = input[i];

        if (ch == '\n') {
            result += game.red * game.green * game.blue;
            game = .{};
            i += 1;
            continue;
        } else if (ch == ' ' or ch == ';' or ch == ',') {
            i += 1;
            continue;
        } else if (std.mem.startsWith(u8, input[i..], "Game ")) {
            i += 6; // skip "Game 0"
            while (std.ascii.isDigit(input[i])) : (i += 1) {}
            i += 2; // skip ": "
            continue;
        }

        var end: usize = i;
        while (std.ascii.isDigit(input[end])) : (end += 1) {}

        const num = std.fmt.parseInt(u8, input[i..end], 10) catch unreachable;

        i = end + 1;
        for (colors) |color| {
            if (std.mem.startsWith(u8, input[i..], color)) {
                const name = std.meta.stringToEnum(ColorName, color).?;

                if (name == .red and game.red < num) {
                    game.red = num;
                } else if (name == .green and game.green < num) {
                    game.green = num;
                } else if (name == .blue and game.blue < num) {
                    game.blue = num;
                }

                i += color.len;
            }
        }
    }

    return result;
}

pub fn main() !void {
    const input = @embedFile("./day2.txt");

    helper.printBenchmark(cubeGame, input);
    helper.printBenchmark(cubePower, input);
}
