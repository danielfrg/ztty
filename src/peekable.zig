const std = @import("std");

pub fn Peekable(comptime T: type, comptime IteratorT: type) type {
    return struct {
        peeked_item: ?T,
        iter: IteratorT,

        pub fn init(iter: IteratorT) @This() {
            return .{
                .iter = iter,
                .peeked_item = null,
            };
        }

        pub fn next(self: *@This()) ?T {
            if (self.peeked_item) |item| {
                self.peeked_item = null;
                return item;
            }
            return self.iter.next();
        }

        pub fn peek(self: *@This()) ?T {
            if (self.peeked_item == null) {
                self.peeked_item = self.iter.next();
            }
            return self.peeked_item;
        }
    };
}
