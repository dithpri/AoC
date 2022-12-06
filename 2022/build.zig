const std = @import("std");
const Builder = std.build.Builder;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};
const allocator = gpa.allocator();

pub fn build(b: *Builder) !void {
    const target = b.standardTargetOptions(.{});
    const mode = b.standardReleaseOptions();
    const run_step = b.step("run", "Run solutions");

    var dir = try std.fs.cwd().openIterableDir(".", .{ .access_sub_paths = true, .no_follow = false });
    defer dir.close();
    //var wlk = try dir.walk(allocator);
    //defer wlk.deinit();
    //while (try wlk.next()) |path| {
    //    std.debug.print("{s}\t{s}\n", .{ path.basename, path.path });
    //}
    var itr = dir.iterate();
    while (try itr.next()) |path| {
        if (std.ascii.startsWithIgnoreCase(path.name, "day_") and path.kind == .Directory) {
            var subdir = try std.fs.cwd().openIterableDir(path.name, .{});
            defer subdir.close();
            var subdir_itr = subdir.iterate();
            while (try subdir_itr.next()) |sub_path| {
                if (sub_path.kind == .File) {
                    const file_path = try std.fs.path.join(allocator, &[_][]const u8{ path.name, sub_path.name });
                    defer allocator.free(file_path);
                    const exe = b.addExecutable(path.name, file_path);
                    exe.setTarget(target);
                    exe.setBuildMode(mode);
                    exe.install();
                    const run_solution = exe.run();
                    run_solution.print = true;
                    const input_path = try std.fs.path.join(allocator, &[_][]const u8{ "inputs", path.name });
                    defer allocator.free(input_path);
                    run_solution.addArg(input_path);
                    run_solution.step.dependOn(b.getInstallStep());
                    run_step.dependOn(&run_solution.step);
                }
            }
        }
    }
}
