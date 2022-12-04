const std = @import("std");
const data = @embedFile("input.txt");
//const data = @embedFile("example.txt");

pub fn main() !void {
    var lines = std.mem.split(u8, data, "\n");

    var total1: u64 = 0;
    while (lines.next()) |line| {
        if (line.len == 0) {
            break;
        }

        const numItems = line.len / 2;
        total1 += toPriority(findSame(line[0..numItems], line[numItems..]));
    }
    std.debug.print("Solution part 1: {any}\n", .{total1});

    var total2: u64 = 0;
    lines = std.mem.split(u8, data, "\n");
    while (lines.next()) |first| {
        if (first.len == 0) {
            break;
        }
        const second = lines.next().?;
        const third = lines.next().?;
        total2 += toPriority(findSame2(first, second, third));
    }
    std.debug.print("Solution part 2: {any}\n", .{total2});
}

fn findSame(first: []const u8, second: []const u8) u8 {
    for (first) |chr| {
        for (second) |other| {
            if (chr == other) {
                return chr;
            }
        }
    }
    std.debug.panic("Shouldn't get here!", .{});
}

fn findSame2(first: []const u8, second: []const u8, third: []const u8) u8 {
    for (first) |chr| {
        for (second) |other| {
            for (third) |last| {
                if (chr == other and other == last) {
                    return chr;
                }
            }
        }
    }
    std.debug.panic("Shouldn't get here!", .{});
}

fn toPriority(chr: u8) u8 {
    if (chr >= 'a' and chr <= 'z') {
        return 1 + chr - 'a';
    } else {
        return 1 + chr - 'A' + 26;
    }
}
