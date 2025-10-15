const std = @import("std");

pub fn Peekable(comptime T: type, comptime Iterator: type) type {
    return struct {
        inner: Iterator,
        peeked_item: ?T,

        pub fn init(inner: Iterator) @This() {
            return .{
                .inner = inner,
                .peeked_item = null,
            };
        }

        pub fn next(self: *@This()) ?T {
            if (self.peeked_item) |item| {
                self.peeked_item = null;
                return item;
            }
            return self.inner.next();
        }

        pub fn peek(self: *@This()) ?T {
            if (self.peeked_item == null) {
                self.peeked_item = self.inner.next();
            }
            return self.peeked_item;
        }
    };
}
