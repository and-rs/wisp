const std = @import("std");

pub const client_id = "Iv23li8yslNT5AaJksdU";

const DeviceCodeResponse = struct {
    device_code: []const u8,
    expires_in: i32,
    interval: i32,
    user_code: []const u8,
    verification_uri: []const u8,
};

pub const LoginDevice = struct {
    user_code: []const u8,
    verification_uri: []const u8,
};

pub const DeviceAuthorization = struct {
    allocator: std.mem.Allocator,
    result: ?std.json.Parsed(DeviceCodeResponse),

    pub fn init(a: std.mem.Allocator) DeviceAuthorization {
        return DeviceAuthorization{ .allocator = a, .result = null };
    }

    pub fn deinit(self: *DeviceAuthorization) void {
        if (self.result) |v| {
            v.deinit();
        }
    }

    pub fn initAuthRequest(self: *DeviceAuthorization, client: *std.http.Client) !void {
        var out: std.Io.Writer.Allocating = .init(client.allocator);
        errdefer out.deinit();

        _ = try client.fetch(.{
            .response_writer = &out.writer,
            .method = .POST,
            .headers = .{
                .content_type = .{ .override = "application/x-www-form-urlencoded" },
            },
            .extra_headers = &.{
                .{ .name = "Accept", .value = "application/json" },
            },
            .location = .{ .url = "https://github.com/login/device/code" },
            .payload = "client_id=" ++ client_id ++ "&scope=read%3Auser",
        });

        self.result = try std.json.parseFromSlice(
            DeviceCodeResponse,
            client.allocator,
            try out.toOwnedSlice(),
            .{ .allocate = .alloc_always },
        );
    }
};
