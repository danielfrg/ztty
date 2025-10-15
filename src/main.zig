const std = @import("std");
const cli = @import("cli.zig");

pub fn main() !void {
    const gpa = std.heap.page_allocator;

    var args = try std.process.argsWithAllocator(gpa);
    defer args.deinit();

    _ = try cli.parseArgs(gpa, args);
}
