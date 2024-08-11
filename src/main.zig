const std = @import("std");
const print = std.debug.print;

const posts_path: []const u8 = "./src/posts";

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    // Record a rather girthy allotment for the buffer for reading files
    const buffer_size: u8 = @as(u8, std.math.maxInt(u8));

    const directory = std.fs.cwd();

    const options = std.fs.Dir.OpenDirOptions{ .iterate = true, .access_sub_paths = true };

    var opened_dir = directory.openDir(posts_path, options) catch |open_err| {
        print("error opening directory for blob posts {}", .{open_err});
        return;
    };
    defer opened_dir.close();

    // Create files with this. Not necessary right now
    // const flags = std.fs.File.CreateFlags{};
    // _ = try opened_dir.createFile("test.md", flags);

    // Set all the iterators as vars to remove const allocation
    var iterator = opened_dir.iterateAssumeFirstIteration();
    while (try iterator.next()) |entry| {
        // std.fmt.bufPrint(buf: []u8, comptime fmt: []const u8, args: anytype)
        // const file_buf: []u8 = undefined;

        const file_buf = try allocator.alloc(u8, buffer_size);
        const path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ posts_path, entry.name });

        const file_data = try directory.readFile(path, file_buf);
        print("{s}", .{file_data});
    }
}
