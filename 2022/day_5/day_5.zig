const std = @import("std");
const stdout = std.io.getStdOut().writer();
var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
const allocator = gpa.allocator();

pub fn main() !void {
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    var stacks_drawing = std.ArrayList([]u8).init(allocator);
    var stacks: [100]?std.ArrayList(u8) = .{null} ** 100;
    var stacks2: [100]?std.ArrayList(u8) = .{null} ** 100;
    var stack_reading = true;
    while (try input_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        if (stack_reading) {
            if (line.len == 0) {
                stack_reading = false;
                while (stacks_drawing.popOrNull()) |repr| {
                    defer allocator.free(repr);
                    var idx: usize = 0;
                    while (idx * 4 < repr.len) : (idx += 1) {
                        const one_indexed = idx + 1;
                        if (repr[idx * 4] == '[') {
                            if (stacks[one_indexed] == null) {
                                stacks[one_indexed] = std.ArrayList(u8).init(allocator);
                            }
                            try stacks[one_indexed].?.append(repr[idx * 4 + 1]);
                        }
                    }
                }
                stacks_drawing.deinit();
                for (stacks) |stack, idx| {
                    if (stack == null) {
                        continue;
                    }
                    stacks2[idx] = try stacks[idx].?.clone();
                }
                continue;
            }
            try stacks_drawing.append(line);
        } else {
            defer allocator.free(line);
            // "move amt from src to dest"
            var itr = std.mem.split(u8, line, " ");
            _ = itr.next();
            const amount = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
            _ = itr.next();
            const src = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
            _ = itr.next();
            const dest = try std.fmt.parseUnsigned(u32, itr.next().?, 10);
            if (stacks[dest] == null) {
                stacks[dest] = std.ArrayList(u8).init(allocator);
            }
            var i: u32 = amount;
            while (i != 0) : (i -= 1) {
                try stacks[dest].?.append(stacks[src].?.pop());
            }
            const len = stacks2[src].?.items.len;
            const newlen = len - amount;
            try stacks2[dest].?.appendSlice(stacks2[src].?.items[newlen..len]);
            try stacks2[src].?.resize(newlen);
        }
    }
    try stdout.print("Part 1: ", .{});
    for (stacks) |stack| {
        if (stack != null) {
            try stdout.print("{c}", .{stack.?.items[stack.?.items.len - 1]});
        }
    }
    try stdout.print("\nPart 2: ", .{});
    for (stacks2) |stack| {
        if (stack != null) {
            try stdout.print("{c}", .{stack.?.items[stack.?.items.len - 1]});
        }
    }
    try stdout.print("\n", .{});
}
