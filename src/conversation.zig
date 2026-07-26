const std = @import("std");

pub const Message = union(enum) {
    user: []const u8,
    tool: []const u8,
    assistant: []const u8,
};

pub const Conversation = struct {
    allocator: std.mem.Allocator,
    messages: std.ArrayList(Message),

    pub fn init(alloc: std.mem.Allocator) Conversation {
        return Conversation{ .allocator = alloc, .messages = .empty };
    }
    pub fn deinit(self: *Conversation) void {
        // order matters...
        for (self.messages.items) |m| {
            switch (m) {
                .user => |v| self.allocator.free(v),
                .tool => |v| self.allocator.free(v),
                .assistant => |v| self.allocator.free(v),
            }
        }
        self.messages.deinit(self.allocator);
    }
    pub fn appendUser(self: *Conversation, message: []const u8) !void {
        const owned_entry = try self.allocator.dupe(u8, message);
        errdefer self.allocator.free(owned_entry);
        try self.messages.append(self.allocator, .{ .user = owned_entry });

        // temporary
        for (self.messages.items, 0..) |m, i| {
            switch (m) {
                inline else => |v| std.debug.print("[{d}] = {s}\n", .{ i, v }),
            }
        }
    }
};
