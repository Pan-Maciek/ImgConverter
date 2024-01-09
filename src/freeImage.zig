const std = @import("std");
const lib = @cImport({
    @cInclude("FreeImage.h");
});

pub fn init() void {
    lib.FreeImage_Initialise(0);
}

pub fn deinit() void {
    lib.FreeImage_DeInitialise();
}

pub fn getCopyrightMessage() [:0]const u8 {
    return std.mem.span(lib.FreeImage_GetCopyrightMessage());
}

const Format = enum(lib.FREE_IMAGE_FORMAT) {
	FIF_UNKNOWN = -1,
	FIF_BMP		= 0,
	FIF_ICO		= 1,
	FIF_JPEG	= 2,
	FIF_JNG		= 3,
	FIF_KOALA	= 4,
	FIF_LBM		= 5,
	FIF_MNG		= 6,
	FIF_PBM		= 7,
	FIF_PBMRAW	= 8,
	FIF_PCD		= 9,
	FIF_PCX		= 10,
	FIF_PGM		= 11,
	FIF_PGMRAW	= 12,
	FIF_PNG		= 13,
	FIF_PPM		= 14,
	FIF_PPMRAW	= 15,
	FIF_RAS		= 16,
	FIF_TARGA	= 17,
	FIF_TIFF	= 18,
	FIF_WBMP	= 19,
	FIF_PSD		= 20,
	FIF_CUT		= 21,
	FIF_XBM		= 22,
	FIF_XPM		= 23,
	FIF_DDS		= 24,
	FIF_GIF     = 25,
	FIF_HDR		= 26,
	FIF_FAXG3	= 27,
	FIF_SGI		= 28,
	FIF_EXR		= 29,
	FIF_J2K		= 30,
	FIF_JP2		= 31,
	FIF_PFM		= 32,
	FIF_PICT	= 33,
	FIF_RAW		= 34,
	FIF_WEBP	= 35,
	FIF_JXR		= 36
};

pub const Image = struct {
    image: ?*lib.FIBITMAP,

    pub fn load(path: [*:0]const u8) !Image {
        const format: Format = @enumFromInt(lib.FreeImage_GetFileType(path, 0));
        if (format == .FIF_UNKNOWN) return error.UnknownFileFormat;

        const image = lib.FreeImage_Load(@intFromEnum(format), path, 0) orelse return error.CouldNotLoadImage;
        defer lib.FreeImage_Unload(image);

        const converted = lib.FreeImage_ConvertTo24Bits(image) orelse return error.CouldNotConvertImage;

        return Image{ .image = converted };
    }

    pub fn unload(self: *const Image) void {
        lib.FreeImage_Unload(self.image);
    }

    pub fn save(self: *const Image, format: Format, path: []const u8) !void {
        
        if (lib.FreeImage_Save(@intFromEnum(format), self.image, path.ptr, 0) == 0) {
            return error.CouldNotSaveFile;
        }
    }
};
