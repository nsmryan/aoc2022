const std = @import("std");
const data = @embedFile("input.txt");
//const data = @embedFile("example.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, data, "\n");

    var total1: u64 = 0;
    var total2: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }
        var parts = std.mem.split(u8, line, ",");
        var first_parts = std.mem.split(u8, parts.next().?, "-");
        var second_parts = std.mem.split(u8, parts.next().?, "-");
        const l0 = try std.fmt.parseInt(u64, first_parts.next().?, 10);
        const h0 = try std.fmt.parseInt(u64, first_parts.next().?, 10);
        const l1 = try std.fmt.parseInt(u64, second_parts.next().?, 10);
        const h1 = try std.fmt.parseInt(u64, second_parts.next().?, 10);

        if (rangeContained(l0, h0, l1, h1)) {
            total1 += 1;
        }

        if (anyOverlap(l0, h0, l1, h1)) {
            total2 += 1;
        }
    }
    std.debug.print("Solution part 1: {any}\n", .{total1});
    std.debug.print("Solution part 2: {any}\n", .{total2});
}

fn rangeWithin(l0: u64, h0: u64, l1: u64, h1: u64) bool {
    return l0 >= l1 and h0 <= h1;
}
fn rangeContained(l0: u64, h0: u64, l1: u64, h1: u64) bool {
    return rangeWithin(l0, h0, l1, h1) or rangeWithin(l1, h1, l0, h0);
}

fn overlap(l0: u64, h0: u64, l1: u64, h1: u64) bool {
    return (l0 >= l1 and l0 <= h1) or (h0 >= l1 and h0 <= h1);
}

fn anyOverlap(l0: u64, h0: u64, l1: u64, h1: u64) bool {
    return overlap(l0, h0, l1, h1) or overlap(l1, h1, l0, h0);
}
