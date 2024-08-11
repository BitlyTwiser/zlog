const std = @import("std");
const print = std.debug.print;

pub fn main() !void {

    // Record a rather girthy allotment for the buffer for reading files
    // const buffer_size: u8 = @as(u8, std.math.maxInt(i32));

    const directory = std.fs.cwd();

    const options = std.fs.Dir.OpenDirOptions{ .iterate = true, .access_sub_paths = true };

    var opened_dir = directory.openDir("./src/posts", options) catch |open_err| {
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
        print("{s}\n", .{entry.name});
    }
}
