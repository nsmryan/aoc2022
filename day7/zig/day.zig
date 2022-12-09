const std = @import("std");
const ArrayList = std.ArrayList;
const Allocator = std.mem.Allocator;
const StringHashMap = std.StringHashMap;

const data = @embedFile("input.txt");
//const data = @embedFile("example.txt");

const Entry = union(enum) {
    file: u64,
    dir: []u8,

    fn file(size: u64) Entry {
        return Entry{ .file = size };
    }

    fn directory(name: []u8) Entry {
        return Entry{ .dir = name };
    }
};

const FileSystem = StringHashMap(ArrayList(Entry));

pub fn main() !void {
    var lines = std.mem.split(u8, data, "\n");

    // Just skip the first line, it doesn't do any good.
    _ = lines.next();

    // Arenas are fun, but not as much fun as fixed sized buffers...
    // Who needs to deallocate anyway?

    //var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    //const allocator = arena.allocator();
    var buffer: [1024 * 100]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator = fba.allocator();

    var total1: u64 = 0;

    var current = ArrayList([]u8).init(allocator);
    try current.append(try allocator.dupe(u8, "/"));
    var fs = FileSystem.init(allocator);
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        if (std.mem.eql(u8, line, "$ ls")) {
            // Nothing to do.
        } else if (std.mem.indexOf(u8, line, "$ cd ..") != null) {
            _ = current.pop();
        } else if (std.mem.indexOf(u8, line, "$ cd") != null) {
            const dirName = line[5..];
            try current.append(try allocator.dupe(u8, dirName));
        } else {
            const path = try makePath(current.items, allocator);
            if (!fs.contains(path)) {
                try fs.put(path, ArrayList(Entry).init(allocator));
            }

            if (std.mem.eql(u8, line[0..4], "dir ")) {
                const dirName = line[4..];
                const dirPath = try std.mem.join(allocator, "/", &[_][]const u8{ path, dirName });
                try fs.getPtr(path).?.append(Entry.directory(try allocator.dupe(u8, dirPath)));
            } else {
                var parts = std.mem.split(u8, line, " ");
                const num = parts.next().?;
                const size = try std.fmt.parseInt(u64, num, 10);
                try fs.getPtr(path).?.append(Entry.file(size));
            }
        }
    }

    // Simple optimization to avoid recalculating directory sizes.
    // Not really necessary, as the program runs fast enough as is.
    // Seems to result in a very slight decrease in runtime, or perhaps a slight increase?
    var cache: StringHashMap(u64) = StringHashMap(u64).init(allocator);
    {
        var keys = fs.keyIterator();
        while (keys.next()) |key| {
            const size = try dirSize(key.*, &fs, &cache);
            if (size <= 100000) {
                total1 += size;
            }
        }
    }

    std.debug.print("Solution part 1: {any}\n", .{total1});

    var total2: u64 = 70000000;
    {
        const free = 70000000 - try dirSize("/", &fs, &cache);
        var keys = fs.keyIterator();
        while (keys.next()) |key| {
            const size = try dirSize(key.*, &fs, &cache);
            if (free + size >= 30000000) {
                total2 = std.math.min(total2, size);
            }
        }
    }
    std.debug.print("Solution part 2: {any}\n", .{total2});
}

fn dirSize(name: []const u8, fs: *const FileSystem, cache: *StringHashMap(u64)) !u64 {
    if (cache.get(name)) |size| {
        return size;
    }

    var total: u64 = 0;
    for (fs.get(name).?.items) |entry| {
        switch (entry) {
            .file => |size| total += size,
            .dir => |subdir| total += try dirSize(subdir, fs, cache),
        }
    }
    try cache.put(name, total);

    return total;
}

fn makePath(path: [][]const u8, allocator: Allocator) ![]u8 {
    if (path.len == 0) {
        return try allocator.dupe(u8, "/");
    } else if (path.len == 1) {
        return try allocator.dupe(u8, path[0]);
    } else {
        return try std.mem.join(allocator, "/", path);
    }
}
