const std = @import("std");

pub const client_id = "Iv23li8yslNT5AaJksdU";
pub const DeviceAuthorization = struct {
    user_id: ?[]const u8,
    device_code: ?[]const u8,
    verification_url: ?[]const u8,

    deadline: std.Io.Clock.Timestamp,
    poll_interval: std.Io.Clock.Duration,

    pub fn requestDeviceCode(client: *std.http.Client) ![]u8 {
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

        return out.toOwnedSlice();
    }

    pub fn init(io: std.Io, interval: u32, expiry: u32) DeviceAuthorization {
        const clock: std.Io.Clock = .boot;
        const now = std.Io.Clock.Timestamp.now(io, clock);

        const interval_duration: std.Io.Clock.Duration = .{
            .raw = std.Io.Duration.fromSeconds(interval),
            .clock = clock,
        };

        const expiry_duration: std.Io.Clock.Duration = .{
            .raw = std.Io.Duration.fromSeconds(expiry),
            .clock = clock,
        };

        return DeviceAuthorization{
            .user_id = null,
            .device_code = null,
            .verification_url = null,
            .poll_interval = interval_duration,
            .deadline = now.addDuration(expiry_duration),
        };
    }

    pub fn deinit() DeviceAuthorization {}
};
