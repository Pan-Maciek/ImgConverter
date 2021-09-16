const std = @import("std");
usingnamespace @cImport({
    @cInclude("FreeImage.h");
});

pub fn init() void {
    FreeImage_Initialise(0);
}

pub fn deinit() void {
    FreeImage_DeInitialise();
}

pub fn getCopyrightMessage() [:0]const u8 {
    return std.mem.span(FreeImage_GetCopyrightMessage());
}

pub const Image = struct {
    const Format = enum_FREE_IMAGE_FORMAT;
    image: ?*FIBITMAP,

    pub fn load(path: []const u8) !Image {
        const format: Format = @intToEnum(Format, FreeImage_GetFileType(path.ptr, 0));
        if (format == .FIF_UNKNOWN) return error.UnknownFileFormat;

        const image = FreeImage_Load(@enumToInt(format), path.ptr, 0) orelse return error.CouldNotLoadImage;
        defer FreeImage_Unload(image);

        const converted = FreeImage_ConvertTo24Bits(image) orelse return error.CouldNotConvertImage;

        return Image{ .image = converted };
    }

    pub fn unload(self: *const Image) void {
        FreeImage_Unload(self.image);
    }

    pub fn save(self: *const Image, format: Format, path: []const u8) !void {
        if (FreeImage_Save(@enumToInt(format), self.image, path.ptr, 0) == 0)
            return error.CouldNotSaveFile;
    }
};
