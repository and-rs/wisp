const std = @import("std");
const vaxis = @import("vaxis");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const allocator = init.gpa;
    var buffer: [1024]u8 = undefined;

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

        text_input.draw(window);
        try vx.render(writer);
    }
}
