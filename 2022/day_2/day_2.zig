const std = @import("std");
const stdout = std.io.getStdOut().writer();
var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
const allocator = gpa.allocator();

const Shape = enum(u2) { Rock = 1, Paper = 2, Scissors = 3 };
const RoundResult = enum(i2) { Loss = -1, Draw = 0, Win = 1 };

inline fn toShape(shape: u8) !Shape {
    return switch (shape) {
        'A' => .Rock,
        'B' => .Paper,
        'C' => .Scissors,
        'Y' => .Paper,
        'X' => .Rock,
        'Z' => .Scissors,
        else => error.InvalidParameter,
    };
}

inline fn toRoundResult(shape: u8) !RoundResult {
    return switch (shape) {
        'Y' => .Draw,
        'X' => .Loss,
        'Z' => .Win,
        else => error.InvalidParameter,
    };
}

inline fn losingShape(shape: Shape) Shape {
    return switch (shape) {
        .Rock => .Scissors,
        .Paper => .Rock,
        .Scissors => .Paper,
    };
}

inline fn winningShape(shape: Shape) Shape {
    return switch (shape) {
        .Rock => .Paper,
        .Paper => .Scissors,
        .Scissors => .Rock,
    };
}

inline fn getShapeScore(shape: Shape) u2 {
    return @enumToInt(shape);
}

inline fn getRoundResult(opponent_shape: Shape, my_shape: Shape) RoundResult {
    const o: i4 = getShapeScore(opponent_shape);
    const m: i4 = getShapeScore(my_shape);
    return @intToEnum(RoundResult, @mod(m - o + 1, 3) - 1);
}

inline fn getRoundScore(opponent_shape: Shape, my_shape: Shape) u4 {
    const result_score: u4 = switch (getRoundResult(opponent_shape, my_shape)) {
        .Loss => 0,
        .Draw => 3,
        .Win => 6,
    };
    return result_score + getShapeScore(my_shape);
}

inline fn getDesiredOutcomeShape(opponent_shape: Shape, secret_code: RoundResult) Shape {
    return switch (secret_code) {
        .Loss => losingShape(opponent_shape),
        .Draw => opponent_shape,
        .Win => winningShape(opponent_shape),
    };
}

pub fn main() !void {
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    var part1: u32 = 0;
    var part2: u32 = 0;
    while (try input_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 32)) |line| {
        defer allocator.free(line);
        var itr = std.mem.split(u8, line, " ");
        // Commented out here is a version using simple modular arithmetic
        // const o: u8 = @enumToInt(try toShape(itr.next().?[0]));
        // const m: u8 = @enumToInt(try toShape(itr.next().?[0]));
        // const d = (o + m) % 3 + 1;
        // part1 += ((4 + m - o) % 3) * 3 + m;
        // part2 += ((4 + d - o) % 3) * 3 + d;
        const opponent_shape = try toShape(itr.next().?[0]);
        const secret_code = itr.next().?[0];
        part1 += getRoundScore(opponent_shape, try toShape(secret_code));
        const desired_shape = getDesiredOutcomeShape(opponent_shape, try toRoundResult(secret_code));
        part2 += getRoundScore(opponent_shape, desired_shape);
    }
    try stdout.print("Part 1: {}\nPart 2: {}\n", .{ part1, part2 });
}
