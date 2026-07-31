const std = @import("std");

pub const Message = union(enum) {
    user: []const u8,
    tool: []const u8,
    assistant: []const u8,
};

/// Whole conversation history that should reach model context
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

    pub fn appendTool(self: *Conversation, message: []const u8) !void {
        const owned_entry = try self.allocator.dupe(u8, message);
        errdefer self.allocator.free(owned_entry);
        try self.messages.append(self.allocator, .{ .tool = owned_entry });
    }
    pub fn appendAssistant(self: *Conversation, message: []const u8) !void {
        const owned_entry = try self.allocator.dupe(u8, message);
        errdefer self.allocator.free(owned_entry);
        try self.messages.append(self.allocator, .{ .assistant = owned_entry });
    }
    pub fn appendUser(self: *Conversation, message: []const u8) !void {
        const owned_entry = try self.allocator.dupe(u8, message);
        errdefer self.allocator.free(owned_entry);
        try self.messages.append(self.allocator, .{ .user = owned_entry });
    }

    pub fn takeUserMsgOwnership(self: *Conversation, message: []const u8) !void {
        errdefer self.allocator.free(message);
        try self.messages.append(self.allocator, .{ .user = message });
    }
};
