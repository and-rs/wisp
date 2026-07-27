const std = @import("std");

pub const DaHttpClient = struct {
    http: std.http.Client,

    pub fn init(io: std.Io, allocator: std.mem.Allocator) !DaHttpClient {
        return DaHttpClient{ .http = .{ .allocator = allocator, .io = io } };
    }
    pub fn deinit(self: *DaHttpClient) void {
        self.http.deinit();
    }
};
