const std = @import("std");
const zap = @import("zap");
const koino = @import("koino");
const print = std.debug.print;

const posts_path: []const u8 = "./src/posts";
const css_path: []const u8 = "<link rel=\"stylesheet\" href=\"html/styles.css\">";

const options = .{
    .extensions = .{
        .autolink = true,
        .strikethrough = true,
        .table = true,
    },
    .render = .{ .hard_breaks = true, .unsafe = true },
};

const generic_request_manifest = struct {
    buffer: null,
    allocator: std.mem.Allocator,
};

var routes: std.StringHashMap([]const u8) = undefined;

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

fn generic_request(r: zap.Request) void {
    // Lookup incoming route in the map, find html, return html
    if (r.path) |path| {
        if (routes.get(path)) |html_body| {
            r.sendBody(html_body) catch return;
        }
    }

    // If route was not found, default to not found. Eventually, make a 404 page or something
    not_found(r);
}

fn not_found(req: zap.Request) void {
    req.sendBody("Not found") catch return;
}

// parser code to inject html/css into pates
fn injectCSS() !void {}

fn injectNavBar() !void {}

// @ToDo(Clean up code, dynamically insert/parse the CSS and the header bar into the markdown pages, make cli tool for deploying. Find somewhere to host code)
// Add timestamp to each article based on when the file was written - THis is a small comment on the markdown page itself perhaps??

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    routes = std.StringHashMap([]const u8).init(allocator);
    // Record a rather girthy allotment for the buffer for reading files
    const buffer_size: u32 = 1024 * 1024 * 2;

    const directory = std.fs.cwd();

    const f_options = std.fs.Dir.OpenDirOptions{ .iterate = true, .access_sub_paths = true };
    var opened_dir = directory.openDir(posts_path, f_options) catch |open_err| {
        print("error opening directory for blog posts {}", .{open_err});
        return;
    };
    defer opened_dir.close();

    var simpleRouter = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer simpleRouter.deinit();

    // Set all the iterators as vars to remove const allocation
    var iterator = opened_dir.iterateAssumeFirstIteration();
    while (try iterator.next()) |entry| {
        // std.fmt.bufPrint(buf: []u8, comptime fmt: []const u8, args: anytype)
        // const file_buf: []u8 = undefined;

        const file_buf = try allocator.alloc(u8, buffer_size);

        // Capture each entry name, these will be the routes displayd
        const request_path = entry.name;
        const path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ posts_path, entry.name });

        const file_data = try directory.readFile(path, file_buf);

        var parser = try koino.parser.Parser.init(allocator, options);
        defer parser.deinit();

        try parser.feed(file_data);

        var doc = try parser.finish();
        defer doc.deinit();

        const buffer = try allocator.alloc(u8, buffer_size); // adjust size based on expected data
        // defer allocator.free(buffer);

        var out_stream = std.io.fixedBufferStream(buffer);
        const writer = out_stream.writer();

        try koino.html.print(writer, allocator, options, doc);

        // Replace MD
        const request_path_simple = try allocator.alloc(u8, request_path.len - 3);
        // defer allocator.free(request_path_simple);

        _ = std.mem.replace(u8, request_path, ".md", "", request_path_simple);
        // Add / into route
        const request_route = try std.fmt.allocPrint(allocator, "/{s}", .{request_path_simple});

        try simpleRouter.handle_func_unbound(request_route, generic_request);
        try routes.put(request_route, out_stream.getWritten());
    }

    var listener = zap.HttpListener.init(.{
        .port = 3000,
        .on_request = simpleRouter.on_request_handler(), // use custom routes from above
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
