const std = @import("std");
const Allocator = std.mem.Allocator;

pub fn changeExtension(allocator: Allocator, path: [*:0]const u8, ext: [:0]const u8) ![:0]const u8 {
    var i = std.mem.len(path) - 1;
    while (i > 1) : (i -= 1) {
        if (path[i] == '.') break;
        if (path[i] == '/' or path[i] == '\\') return error.NoExtension;
    } else return error.NoExtension;
    if (path[i - 1] == '.' or path[i - 1] == '\\' or path[i - 1] == '/')
        return error.NoExtension;

    var concat = try allocator.allocSentinel(u8, i + ext.len, 0);
    std.mem.copy(u8, concat, path[0..i]);
    std.mem.copy(u8, concat[i..], ext);
    return concat;
}
