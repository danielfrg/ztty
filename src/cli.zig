const std = @import("std");
const Peekable = @import("peekable.zig").Peekable;

const Options = struct {
    stdin: []const u8 = "",
    stdout: []const u8 = "",
};

const ParseOptionsError = error{
    MissingRequiredValue,
    InvalidValue,
    UnknownArgument,
};

fn parseArg(
    iter: anytype,
    arg: []const u8,
) ![]const u8 {
    if (iter.peek()) |peaked_value| {
        // Parsed the value, so we can now consume it and return it
        _ = iter.next();
        return peaked_value;
    } else {
        std.debug.print("Error: Value required for {s}\n", .{arg});
        return ParseOptionsError.MissingRequiredValue;
    }
}

pub fn parseArgs(args: anytype) !Options {
    var iter = Peekable([]const u8, @TypeOf(args)).init(args);

    // Skip the first argument, which is the path to the executable.
    _ = iter.next();

    var options = Options{
        .stdin = "stdin",
        .stdout = "stdout",
    };

    while (iter.next()) |arg| {
        std.debug.print("parsing: {s}\n", .{arg});

        if (std.mem.eql(u8, arg, "--stdin")) {
            options.stdin = try parseArg(&iter, arg);
        } else if (std.mem.eql(u8, arg, "--stdout")) {
            options.stdout = try parseArg(&iter, arg);
        } else {
            std.debug.print("Error: Unknown argument: {s}\n", .{arg});
            return ParseOptionsError.UnknownArgument;
        }
    }

    return options;
}

test "parse one option" {
    const testing = std.testing;
    const alloc = testing.allocator;

    var iter = try std.process.ArgIteratorGeneral(.{}).init(
        alloc,
        "ztty --stdin infile",
    );
    defer iter.deinit();

    const options = try parseArgs(iter);

    try testing.expectEqualStrings(options.stdin, "infile");
    try testing.expectEqualStrings(options.stdout, "stdout");
}

test "parse multiple options" {
    const testing = std.testing;
    const alloc = testing.allocator;

    var iter = try std.process.ArgIteratorGeneral(.{}).init(
        alloc,
        "ztty --stdin infile --stdout outfile",
    );
    defer iter.deinit();

    const options = try parseArgs(iter);

    try testing.expectEqualStrings(options.stdin, "infile");
    try testing.expectEqualStrings(options.stdout, "outfile");
}
