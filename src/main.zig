const std = @import("std");
const vaxis = @import("vaxis");
const layout = @import("layout.zig");
const conversation = @import("conversation.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var buffer: [1024]u8 = undefined;

    var convo = conversation.Conversation.init(allocator);
    defer convo.deinit();

    try convo.appendUser("yo biatch");

    const Event = union(enum) {
        winsize: vaxis.Winsize,
        key_press: vaxis.Key,
    };

    var tty = try vaxis.Tty.init(io, &buffer);
    defer tty.deinit();

    const writer = tty.writer();
    var vx = try vaxis.init(io, allocator, init.environ_map, .{});
    defer vx.deinit(allocator, writer);

    var loop: vaxis.Loop(Event) = .init(io, &tty, &vx);
    try vx.enterAltScreen(writer);

    try loop.start();
    defer loop.stop();

    try vx.queryTerminal(writer, std.Io.Duration.fromSeconds(1));

    var text_input = vaxis.widgets.TextInput.init(allocator);
    defer text_input.deinit();

    while (true) {
        const event = try loop.nextEvent();
        switch (event) {
            .winsize => |ws| try vx.resize(allocator, writer, ws),
            .key_press => |key| {
                if (key.matches('x', .{ .ctrl = true })) {
                    break;
                } else {
                    try text_input.update(.{ .key_press = key });
                }
            },
        }
        const window = vx.window();
        window.clear();

        const split_layout = layout.Layout.init(window);
        text_input.draw(split_layout.input);

        try vx.render(writer);
    }
}
