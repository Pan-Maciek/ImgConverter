const std = @import("std");
const freeImage = @import("./freeImage.zig");
const fs = @import("./fs.zig");

const Image = freeImage.Image;

pub fn main() !void {
    var buffer: [256]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    var allocator = &fba.allocator;

    std.debug.print("{s}\n", .{freeImage.getCopyrightMessage()});

    freeImage.init();
    defer freeImage.deinit();

    for (std.mem.span(std.os.argv)[1..]) |_path| {
        const path = std.mem.span(_path);

        const img = Image.load(path) catch |err| {
            std.log.warn("Error while processing {s}. Cause: {s}", .{ path, @errorName(err) });
            continue;
        };
        defer img.unload();

        const new_path = fs.changeExtension(allocator, path, ".jpg") catch unreachable;
        defer fba.reset();

        img.save(.FIF_JPEG, new_path) catch |err| {
            std.log.warn("Error while saving {s}. Cause: {s}", .{ new_path, @errorName(err) });
            continue;
        };
    }
}
