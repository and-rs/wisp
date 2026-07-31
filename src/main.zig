const std = @import("std");
const vaxis = @import("vaxis");

const ev = @import("events.zig");
const sn = @import("system_notifications.zig");
const layout = @import("layout.zig");
const cnv = @import("conversation.zig");

const copilot = @import("providers/copilot.zig");
const hcs = @import("providers/http.zig");

const Command = enum { login, quit };
const commands = std.StaticStringMap(Command).initComptime(.{
    .{ "/login", .login },
    .{ "/quit", .quit },
});

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var buffer: [1024]u8 = undefined;

    var request_client = try hcs.DaHttpClient.init(io, allocator);
    defer request_client.deinit();

    var tty = try vaxis.Tty.init(io, &buffer);
    defer tty.deinit();

    const writer = tty.writer();
    var vx = try vaxis.init(io, allocator, init.environ_map, .{});
    defer vx.deinit(allocator, writer);

    var loop: vaxis.Loop(ev.Event) = .init(io, &tty, &vx);
    try vx.enterAltScreen(writer);

    try loop.start();
    defer loop.stop();

    try vx.queryTerminal(writer, std.Io.Duration.fromSeconds(1));

    // Initialize main text input
    var text_input = vaxis.widgets.TextInput.init(allocator);
    defer text_input.deinit();

    // Initialize conversation, notifications and copilot POC
    var conversation = cnv.Conversation.init(allocator);
    defer conversation.deinit();
    var system_notifications = sn.SystemNotifications.init(allocator);
    defer system_notifications.deinit();
    var copilot_auth = copilot.DeviceAuthorization.init(allocator);
    defer copilot_auth.deinit();

    while (true) {
        const event = try loop.nextEvent();
        switch (event) {
            .winsize => |ws| try vx.resize(allocator, writer, ws),
            .key_press => |key| {
                if (key.matches('x', .{ .ctrl = true })) {
                    break;
                }

                if (key.matches(vaxis.Key.enter, .{})) {
                    var contents: ?[]const u8 = try text_input.toOwnedSlice();
                    defer if (contents) |v| {
                        allocator.free(v);
                    };
                    if (contents == null) {
                        continue;
                    }

                    if (commands.get(contents.?)) |command| {
                        switch (command) {
                            .quit => {
                                break;
                            },
                            .login => {
                                try copilot_auth.initAuthRequest(&request_client.http);
                                if (copilot_auth.result) |j| {
                                    try system_notifications.takeSystemMsgOwnership(j.value.verification_uri);
                                }
                                contents = null;
                            },
                        }
                    }

                    try conversation.takeUserMsgOwnership(contents);
                } else {
                    try text_input.update(.{ .key_press = key });
                }
            },
        }
        const window = vx.window();
        window.clear();

        const split_layout = layout.Layout.init(window);
        var current_row: u16 = 0;

        for (system_notifications.messages.items) |m| {
            switch (m) {
                .notice => |v| {
                    const last_print = split_layout.history.print(&.{
                        .{ .text = "<System> ", .style = .{ .fg = .{ .index = 1 } } },
                        .{ .text = v },
                    }, .{ .row_offset = current_row });
                    current_row = last_print.row + 1;
                },
            }
        }

        for (conversation.messages.items) |m| {
            switch (m) {
                .user => |v| {
                    const last_print = split_layout.history.print(&.{
                        .{ .text = "<User> ", .style = .{ .fg = .{ .index = 2 } } },
                        .{ .text = v },
                    }, .{ .row_offset = current_row });
                    current_row = last_print.row + 1;
                },
                .tool => |v| {
                    const last_print = split_layout.history.print(&.{
                        .{ .text = "<Tool> ", .style = .{ .fg = .{ .index = 3 } } },
                        .{ .text = v },
                    }, .{ .row_offset = current_row });
                    current_row = last_print.row + 1;
                },
                .assistant => |v| {
                    const last_print = split_layout.history.print(&.{
                        .{ .text = "<Assistant> ", .style = .{ .fg = .{ .index = 4 } } },
                        .{ .text = v },
                    }, .{ .row_offset = current_row });
                    current_row = last_print.row + 1;
                },
            }
        }

        // before text_input render/draw
        text_input.draw(split_layout.input);
        try vx.render(writer);
    }
}
