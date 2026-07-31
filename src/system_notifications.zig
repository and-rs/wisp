const std = @import("std");

pub const System = union(enum) {
    notice: []const u8,
    // might expand this later
};

/// User facing system notifications in the UI that do not get to the context.
pub const SystemNotifications = struct {
    allocator: std.mem.Allocator,
    messages: std.ArrayList(System),

    pub fn init(alloc: std.mem.Allocator) SystemNotifications {
        return SystemNotifications{ .allocator = alloc, .messages = .empty };
    }
    pub fn deinit(self: *SystemNotifications) void {
        // order matters...
        for (self.messages.items) |m| {
            switch (m) {
                .notice => |v| self.allocator.free(v),
            }
        }
        self.messages.deinit(self.allocator);
    }

    pub fn appendSystem(self: *SystemNotifications, message: []const u8) !void {
        const owned_entry = try self.allocator.dupe(u8, message);
        errdefer self.allocator.free(owned_entry);
        try self.messages.append(self.allocator, .{ .notice = owned_entry });
    }
    pub fn takeSystemMsgOwnership(self: *SystemNotifications, message: []const u8) !void {
        errdefer self.allocator.free(message);
        try self.messages.append(self.allocator, .{ .notice = message });
    }
};
