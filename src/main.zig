const std = @import("std");
const zap = @import("zap");
const koino = @import("koino");
const print = std.debug.print;

const posts_path: []const u8 = "./src/posts";

const options = .{
    .extensions = .{
        .autolink = true,
        .strikethrough = true,
        .table = true,
    },
    .render = .{ .hard_breaks = true, .unsafe = true },
};

// Parse all files, split MD, these are the routes.
// Read all the markdown, this is the content of each blob post
// Push to the web server for both the main HTML page and the inner contents
// Each blob is going to be past in via Mustache, then the user can click the link rendering the content (Markdown)
// Thus we:
// 1. Dynamically build the routes
// 2. Render the content for each blog post - This is more annoying as its markdown, so we need to parse it
// 3. Allow users to click content
// 4. Use no web framework, only zig
// We still need a github action to deploy (probably to digital ocean)
// Get a DNS nam reserved
// Setup HTTPS with letrencrypt

fn on_request(r: zap.Request) void {
    if (r.path) |the_path| {
        std.debug.print("PATH: {s}\n", .{the_path});
    }

    if (r.query) |the_query| {
        std.debug.print("QUERY: {s}\n", .{the_query});
    }
    r.sendBody("<html><body><h1>Hello from ZAP!!!</h1><code>std = @import(\"std\")</code></body></html>") catch return;
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    // Record a rather girthy allotment for the buffer for reading files
    const buffer_size: u8 = @as(u8, std.math.maxInt(u8));

    const directory = std.fs.cwd();

    const f_options = std.fs.Dir.OpenDirOptions{ .iterate = true, .access_sub_paths = true };
    var opened_dir = directory.openDir(posts_path, f_options) catch |open_err| {
        print("error opening directory for blog posts {}", .{open_err});
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

        // Capture each entry name, these will be the routes displayd
        print("{s}\n", .{entry.name});
        const path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ posts_path, entry.name });

        const file_data = try directory.readFile(path, file_buf);

        var parser = try koino.parser.Parser.init(allocator, options);
        defer parser.deinit();

        try parser.feed(file_data);

        var doc = try parser.finish();
        defer doc.deinit();

        const buffer = try allocator.alloc(u8, 1024); // adjust size based on expected data
        defer allocator.free(buffer);

        var out_stream = std.io.fixedBufferStream(buffer);
        const writer = out_stream.writer();

        try koino.html.print(writer, allocator, options, doc);

        print("{s}", .{out_stream.getWritten()});
    }

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = on_request,
        .log = true,
    });
    try listener.listen();

    std.debug.print("Listening on 0.0.0.0:3000\n", .{});

    // start worker threads
    zap.start(.{
        .threads = 2,
        .workers = 2,
    });
}
