const std = @import("std");
const zap = @import("zap");
const koino = @import("koino");
const print = std.debug.print;

const posts_path: []const u8 = "./src/posts";
const html_path: []const u8 = "./src/html";
const css_path_file: []const u8 = html_path ++ "/styles.css";
const nav_bar_path: []const u8 = html_path ++ "/nav_bar.html";
const not_found_path: []const u8 = html_path ++ "/404.html";
const css_path_dynamic: []const u8 = "<link rel=\"stylesheet\" href=\"html/styles.css\">";

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

const directory_opener = struct {
    const Self = @This();

    directory: std.fs.Dir,
    opened_directory: std.fs.Dir,

    fn deinit(self: *Self) void {
        self.opened_directory.close();
    }
};

// Record a rather girthy allotment for the buffer for reading files
const buffer_size: u32 = 1024 * 1024 * 2;

const NotFound = error{PostsNotFound};

const InjectionType = enum {
    CSS,
    NavBar,
    NotFound,

    fn path(self: InjectionType) []const u8 {
        switch (self) {
            .CSS => {
                return css_path_file;
            },
            .NavBar => {
                return nav_bar_path;
            },
            .NotFound => {
                return not_found_path;
            },
        }
    }

    fn bufferSize(self: InjectionType) u32 {
        switch (self) {
            .CSS => {
                return 1024 * 4;
            },
            .NavBar => {
                return 900;
            },
            .NotFound => {
                return 1024 * 2;
            },
        }
    }
};

var routes: std.StringHashMap([]const u8) = undefined;

// Parse all files, split MD, these are the routes.
// Read all the markdown, this is the content of each blob post
// Push to the web server for both the main HTML page and the inner contents
// Each blob is going to be past in via Mustache, then the user can click the link rendering the content (Markdown)
// Thus we:
// 1. Dynamically build the routes [x]
// 2. Render the content for each blog post - This is more annoying as its markdown, so we need to parse it [x]
// 3. Allow users to click content [x]?
// 4. Use no web framework, only zig [x]
// 5. Dynamically insert blog posts now []
// 6.  github action to deploy (probably to digital ocean) []
// 7. Get a DNS nam reserved []
// 8. Setup HTTPS with letrencrypt []

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
    const allocator = std.heap.page_allocator;
    const not_found_body = allocateAndReturnFileData(allocator, InjectionType.NotFound) catch "Not found";
    defer allocator.free(not_found_body);

    req.sendBody(not_found_body) catch return;
}

fn allocateAndReturnFileData(allocator: std.mem.Allocator, i_type: InjectionType) ![]u8 {
    const dir = std.fs.cwd();

    const file_buf = try allocator.alloc(u8, i_type.bufferSize());
    const bytes_read = try dir.readFile(i_type.path(), file_buf);

    const reallocated_buf = try allocator.realloc(file_buf, bytes_read.len);
    // RE-alloc to fit how many bytes were actually read to avoid null-bytes
    if (i_type == InjectionType.CSS) {
        const css_data = try std.fmt.allocPrint(allocator, "<style>\n{s}\n</style>", .{reallocated_buf});
        return try allocator.realloc(css_data, bytes_read.len);
    }

    return reallocated_buf;
}

fn openDirectory(path: []const u8) NotFound!directory_opener {
    const directory = std.fs.cwd();

    const f_options = std.fs.Dir.OpenDirOptions{ .iterate = true, .access_sub_paths = true };
    const opened_dir = directory.openDir(path, f_options) catch {
        return NotFound.PostsNotFound;
    };

    return directory_opener{ .directory = directory, .opened_directory = opened_dir };
}

fn setRoutes(allocator: std.mem.Allocator, simpleRouter: *zap.Router) !void {
    var opened_dir = openDirectory(posts_path) catch |e| {
        switch (e) {
            NotFound.PostsNotFound => {
                print("error opening directory for blog posts {s} make sure path exists", .{posts_path});
            },
        }
        return;
    };
    defer opened_dir.deinit();

    var iterator = opened_dir.opened_directory.iterateAssumeFirstIteration();
    while (try iterator.next()) |entry| {
        const file_buf = try allocator.alloc(u8, buffer_size);

        // Capture each entry name, these will be the routes displayd
        const request_path = entry.name;
        const path = try std.fmt.allocPrint(allocator, "{s}/{s}", .{ posts_path, entry.name });

        const file_data = try opened_dir.directory.readFile(path, file_buf);

        // Inject both the css and the navbar here
        const css = try allocateAndReturnFileData(allocator, InjectionType.CSS);
        const nav_bar = try allocateAndReturnFileData(allocator, InjectionType.NavBar);

        const dyanmic_html = try std.fmt.allocPrint(allocator, "{s}\n{s}\n{s}", .{ nav_bar, file_data, css });

        // Actual Markdown parsing, thanks Koino
        var parser = try koino.parser.Parser.init(allocator, options);
        defer parser.deinit();

        try parser.feed(dyanmic_html);

        var doc = try parser.finish();
        defer doc.deinit();

        // Buffer allocations to pass the html data around into the routes
        const buffer = try allocator.alloc(u8, buffer_size); // adjust size based on expected data
        // defer allocator.free(buffer);
        var out_stream = std.io.fixedBufferStream(buffer);
        const writer = out_stream.writer();

        try koino.html.print(writer, allocator, options, doc);

        // Replace MD for route name
        const request_path_simple = try allocator.alloc(u8, request_path.len - 3);
        // defer allocator.free(request_path_simple);

        _ = std.mem.replace(u8, request_path, ".md", "", request_path_simple);
        // Add / into route(s)
        const request_route = try std.fmt.allocPrint(allocator, "/{s}", .{request_path_simple});

        // Store in router and in the routes StringsHashMap
        try simpleRouter.handle_func_unbound(request_route, generic_request);
        try routes.put(request_route, out_stream.getWritten());
    }
}

// @ToDo(Clean up code, dynamically insert/parse the CSS and the header bar into the markdown pages, make cli tool for deploying. Find somewhere to host code)
// Add timestamp to each article based on when the file was written - THis is a small comment on the markdown page itself perhaps??
pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Records all routes
    routes = std.StringHashMap([]const u8).init(allocator);

    // Create zap routes and routes
    var simpleRouter = zap.Router.init(allocator, .{
        .not_found = not_found,
    });
    defer simpleRouter.deinit();

    try setRoutes(allocator, &simpleRouter);

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
