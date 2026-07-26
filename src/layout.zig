const vaxis = @import("vaxis");

pub const Layout = struct {
    history: vaxis.Window,
    input: vaxis.Window,

    pub fn init(root: vaxis.Window) Layout {
        const input_height = @min(root.height, 3);
        const input_y = root.height - input_height;
        const history_height = input_y;

        return Layout{
            .history = root.child(.{ .height = history_height }),
            .input = root.child(.{
                .height = input_height,
                .y_off = input_y,
                .border = .{ .where = .all, .glyphs = .single_square },
            }),
        };
    }
};
