const std = @import("std");
const stdout = std.io.getStdOut().writer();
var gpa = (std.heap.GeneralPurposeAllocator(.{}){});
const allocator = gpa.allocator();

inline fn itemPriority(item: u8) !u8 {
    if (item >= 'a' and item <= 'z') {
        return item - 'a' + 1;
    } else if (item >= 'A' and item <= 'Z') {
        return item - 'A' + 27;
    }
    return error.InvalidParameter;
}

inline fn printSet(set: @TypeOf(std.bit_set.StaticBitSet(52 + 1).initFull())) !void {
    var ite = set.iterator(.{});
    while (ite.next()) |val| {
        var letter: u8 = '?';
        if (val > 26 and val < 53) {
            letter = @intCast(u8, val + 'A' - 27);
        } else if (val <= 26) {
            letter = @intCast(u8, val + 'a' - 1);
        } else {
            return error.InvalidParameter;
        }
        std.debug.print("{c}", .{letter});
    }
}

pub fn main() !void {
    const input_file = try std.fs.cwd().openFileZ(std.os.argv[1], .{});
    defer input_file.close();
    var part1: u32 = 0;
    var part2: u32 = 0;
    var elf_ctr: u8 = 0;
    var common_items: ?@TypeOf(std.bit_set.StaticBitSet(52 + 1).initFull()) = null;
    while (try input_file.reader().readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        defer allocator.free(line);
        var compartment1 = std.bit_set.StaticBitSet(52 + 1).initEmpty();
        var compartment2 = std.bit_set.StaticBitSet(52 + 1).initEmpty();
        for (line[0 .. line.len / 2]) |char| {
            compartment1.set(try itemPriority(char));
        }
        for (line[line.len / 2 .. line.len]) |char| {
            compartment2.set(try itemPriority(char));
        }
        part1 += @intCast(u32, compartment1.intersectWith(compartment2).findFirstSet().?);
        if (common_items == null) {
            common_items = compartment1.unionWith(compartment2);
        }
        common_items.?.setIntersection(compartment1.unionWith(compartment2));
        elf_ctr += 1;
        elf_ctr %= 3;
        if (elf_ctr == 0) {
            part2 += @intCast(u32, common_items.?.findFirstSet().?);
            common_items = null;
        }
    }
    try stdout.print("Part 1: {}\nPart 2: {}\n", .{ part1, part2 });
}
