const std = @import("std");
const assert = std.debug.assert;
const SubIndex = @import("SubIndex.zig");
/// Solves sudoku automatically
/// 1. allows putting in
///
///
board1: [9][9]u16, // bit board - shows all possible values
board2: [9][9]u8, // board - shows final value as character

pub fn init() @This() {
    return @This(){
        .board1 = @bitCast(@as(@Vector(81, u16), @splat(0b111111111))),
        .board2 = @bitCast(@as(@Vector(81, u8), @splat('0'))),
    };
}

pub fn setIndex(self: *@This(), value: u8, index: u8) void {
    assert(value >= 1 and value <= 9);
    assert(index >= 0 and index <= 81);
    const subIndex = indexToSubIndex(index);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << value;
}

pub fn setIndices(self: *@This(), values: []u8, indices: []u8) void {
    assert(values.len == indices.len);
    for (values, indices) |value, index|
        self.setIndex(value, index);
}

pub fn setSubIndex(self: *@This(), value: u8, subIndex: SubIndex) void {
    assert(value >= 1 and value <= 9);
    assert(subIndex.row >= 0 and subIndex.row < 9);
    assert(subIndex.col >= 0 and subIndex.col < 9);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << value;
}

pub fn setSubIndices(self: *@This(), values: []u8, subIndices: []SubIndex) void {
    assert(values.len == subIndices.len);
    for (values, subIndices) |value, subIndex| {
        self.setSubIndex(value, subIndex);
    }
}

pub fn unsetIndex(self: *@This(), value: u8, index: u8) void {
    assert(value >= 0 and value < 9);
    assert(index >= 0 and index < 81);
    const 
}

pub fn unsetIndices(self: *@This(), values: []u8, indices: []u8) void {}

pub fn unsetSubIndex(self: *@This(), value: u8, index: u8) void {}

pub fn unsetSubIndices(self: *@This(), value: u8, indices: []u8) void {}

pub fn solve(self: *@This()) void {
    const v: @Vector(81, u8) = @splat('0');
    var i: usize = 0;
    while (@reduce(.Or, @as(@Vector(81, u8), self.board) == v)) : (i += 1) {
        if (i > 10) break;
        self.print();
    }
}

pub fn printPossibities(self: *const @This()) void {
    for (self.board1) |row| {
        for (row) |col| {
            std.debug.print("{b} ", .{self.board[row][col]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

pub fn print(self: *const @This()) void {
    for (self.board2) |row| {
        for (row) |col| {
            std.debug.print("{c} ", .{self.board[row][col]});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

pub fn indexToSubIndex(index: usize) SubIndex {
    return SubIndex{
        .row = index / 9,
        .col = index % 9,
    };
}
