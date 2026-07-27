const vaxis = @import("vaxis");

pub const Event = union(enum) {
    winsize: vaxis.Winsize,
    key_press: vaxis.Key,
    const ProviderEvent = union(enum) {
        text_delta: []const u8,
        failed: []const u8,
        complete,
    };
};
