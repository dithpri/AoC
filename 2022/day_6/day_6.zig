const std = @import("std");
const stdout = std.io.getStdOut().writer();
var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
const allocator = gpa.allocator();

fn CircularBuffer(comptime T: type, comptime size: usize) type {
    return struct {
        const Self = @This();
        items: [size]T,
        next_write: usize = 0,
        pub fn write(self: *Self, data: T) void {
            self.items[self.next_write] = data;
            self.next_write +%= 1;
            self.next_write %= size;
        }
        pub fn raw_buf(self: *Self) []const T {
            return self.items[0..size];
        }
    };
}

fn getDistinctCharsPosition(data: []u8, comptime window_size: usize) ?usize {
    var buf = CircularBuffer(u8, window_size){ .items = .{undefined} ** window_size };
    return for (data) |char, idx| {
        buf.write(char);
        if (idx < 4) {
            continue;
        }
        var set = std.bit_set.StaticBitSet(1 << @bitSizeOf(u8)).initEmpty();
        for (buf.raw_buf()) |c| {
            set.set(c);
        }
        if (set.count() == window_size) {
            break idx + 1;
        }
    } else null;
}

pub fn main() !void {
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    const fsize = try input_file.getEndPos();
    const data = try input_file.readToEndAlloc(allocator, fsize);
    try stdout.print("Part 1: {?}\nPart 2: {?}\n", .{ getDistinctCharsPosition(data, 4), getDistinctCharsPosition(data, 14) });
}
