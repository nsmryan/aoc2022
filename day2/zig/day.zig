const std = @import("std");
const data = @embedFile("input.txt");
//const data = @embedFile("example.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, data, "\n");
    //var totals = std.ArrayList(u64).init(std.heap.page_allocator);
    var total1: i64 = 0;
    var total2: i64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        const first = @intCast(i64, line[0] - 'A');
        const second = @intCast(i64, line[2] - 'X');
        total1 += @mod(second + 2 * first + 1, 3) * 3 + second + 1;
        total2 += second * 3 + @mod(second + first + 2, 3) + 1;
    }
    std.debug.print("Solution part 1: {}\n", .{total1});
    std.debug.print("Solution part 2: {}\n", .{total2});
}
