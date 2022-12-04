const std = @import("std");
const data = @embedFile("input.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, data, "\n");
    var totals = std.ArrayList(u64).init(std.heap.page_allocator);
    var current: u64 = 0;
    while (lines.next()) |line| {
        if (line.len > 0) {
            current += try std.fmt.parseInt(u64, line, 10);
        } else {
            try totals.append(current);
            current = 0;
        }
    }
    std.sort.sort(u64, totals.items, {}, std.sort.desc(u64));
    std.debug.print("Solution part 1: {}\n", .{totals.items[0]});
    std.debug.print("Solution part 2: {}\n", .{totals.items[0] + totals.items[1] + totals.items[2]});
}
