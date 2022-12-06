const std = @import("std");
const stdout = std.io.getStdOut().writer();
var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
const allocator = gpa.allocator();

const Range = std.bit_set.Range;
fn parseRanges(line: []const u8) ![2](Range) {
    var itr = std.mem.split(u8, line, ",");
    const range1 = itr.next().?;
    const range2 = itr.next().?;
    itr = std.mem.split(u8, range1, "-");
    const range1_start = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
    const range1_end = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
    itr = std.mem.split(u8, range2, "-");
    const range2_start = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
    const range2_end = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
    return .{ .{ .start = range1_start, .end = range1_end }, .{ .start = range2_start, .end = range2_end } };
}

inline fn rangeContains(a: Range, b: Range) bool {
    return a.start >= b.start and a.end <= b.end;
}

inline fn rangesSubSupSets(a: Range, b: Range) bool {
    return rangeContains(a, b) or rangeContains(b, a);
}

inline fn rangesOverlap(a: Range, b: Range) bool {
    return (a.start >= b.start and a.start <= b.end) or (a.start <= b.start and a.end >= b.start);
}

pub fn main() !void {
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    var part1: u32 = 0;
    var part2: u32 = 0;
    while (try input_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        defer allocator.free(line);
        const ranges = try parseRanges(line);
        const r1 = ranges[0];
        const r2 = ranges[1];
        part1 += @boolToInt(rangesSubSupSets(r1, r2));
        part2 += @boolToInt(rangesOverlap(r1, r2));
    }
    try stdout.print("Part 1: {}\nPart 2: {}\n", .{ part1, part2 });
}
