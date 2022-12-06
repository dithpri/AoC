const std = @import("std");
const stdout = std.io.getStdOut().writer();

pub fn replaceSmallestIfLarger(comptime T: type, array: []T, value: T) void {
    const asc_T = comptime (std.sort.asc(T));
    const minidx = std.sort.argMin(T, array, {}, asc_T).?;
    array[minidx] = std.math.max(array[minidx], value);
}

pub fn sum(comptime T: type, array: []T) T {
    var ret: T = 0;
    for (array) |item| {
        ret += item;
    }
    return ret;
}

pub fn main() !void {
    var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
    const allocator = gpa.allocator();
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    var max_calories: [3]u32 = .{ 0, 0, 0 };
    var current_calories: u32 = 0;
    while (try input_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 32)) |line| {
        defer allocator.free(line);
        if (line.len == 0) {
            replaceSmallestIfLarger(u32, &max_calories, current_calories);
            current_calories = 0;
            continue;
        }
        const calories = try std.fmt.parseUnsigned(u32, line, 10);
        current_calories += calories;
    }
    try stdout.print("Part 1: {}\nPart 2: {}\n", .{ std.sort.max(u32, &max_calories, {}, comptime std.sort.asc(u32)).?, sum(u32, &max_calories) });
}
