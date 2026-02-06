const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const SubIndex = @import("SubIndex.zig");

/// Sum of a row/col/block
const COMPLETED_SUM = blk: {
    var sum: usize = 0;
    for (0..9) |i| sum += 1;
    break :blk sum;
};

/// Solves sudoku board automatically
/// 1. sets up board with values
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

pub fn setIndex(self: *@This(), index: u8, value: u8) void {
    assert(value < 9);
    assert(index < 81);
    const subIndex = indexToSubIndex(index);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << value;
}

pub fn setIndices(self: *@This(), indices: []u8, values: []u8) void {
    assert(values.len == indices.len);
    assert(values.len < 81);
    for (values, indices) |value, index|
        self.setIndex(value, index);
}

pub fn setSubIndex(self: *@This(), subIndex: SubIndex, value: u8) void {
    assert(value < 9);
    assert(subIndex.row < 9 and subIndex.col < 9);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << value;
}

pub fn setSubIndices(self: *@This(), subIndices: []SubIndex, values: []u8) void {
    assert(values.len == subIndices.len);
    assert(values.len < 81);
    for (values, subIndices) |value, subIndex| {
        self.setSubIndex(value, subIndex);
    }
}

pub fn unsetIndex(self: *@This(), index: u8, value: u8) void {
    assert(value < 9);
    assert(index < 81);
    const subIndex = indexToSubIndex(index);
    self.board1[subIndex.row][subIndex.col] &= ~(@as(u16, 1) << value);
}

pub fn unsetIndices(self: *@This(), indices: []u8, values: []u8) void {
    assert(values.len == indices.len);
    for (values, indices) |value, index|
        self.unsetIndex(value, index);
}

pub fn unsetSubIndex(self: *@This(), subIndex: SubIndex, value: u8) void {
    assert(value < 9);
    assert(subIndex.row < 9 and subIndex.col < 9);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << value;
}

pub fn unsetSubIndices(self: *@This(), subIndices: []u8, values: []u8) void {
    assert(values.len == subIndices.len);
    for (values, subIndices) |value, subIndex|
        self.unsetSubIndex(value, subIndex);
}

pub fn solve(self: *@This()) void {
    const v: @Vector(81, u8) = @splat(0);
    var i: usize = 0;
    while (@reduce(.Or, @as(@Vector(81, u8), self.board) == v)) : (i += 1) {
        if (i > 10) break;
        self.print();
    }
}

fn isRowSolved(self: *const @This(), row: usize) bool {
    return @reduce(.Add, @as(@Vector(9, u8), self.board2[0]));
}

fn isColSolved(self: *const @This(), col: usize) bool {}

pub fn printPossibities(self: *const @This()) void {
    std.debug.print("Possibilities:\n", .{});
    for (self.board1) |row| {
        for (row) |col| {
            std.debug.print("{b} ", .{col});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

pub fn print(self: *const @This()) void {
    std.debug.print("Solution:\n", .{});
    for (self.board2) |row| {
        for (row) |col| {
            std.debug.print("{c} ", .{col + 'a' - 1});
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

test "Init" {
    const sudoku: @This() = .init();
    for (sudoku.board1) |row| {
        for (row) |col| testing.expect(col == 0b111111111);
    }
    for (sudoku.board2) |row| {
        for (row) |col| testing.expect(col == '0');
    }
}

test "Set/Unset Index" {
    var sudoku: @This() = .init();

    sudoku.setIndex(1, 3);
    sudoku.setIndex(2, 9);
    sudoku.setIndex(6, 1);

    testing.expect(sudoku.board1[0][1] == 3);
    testing.expect(sudoku.board1[0][2] == 9);
    testing.expect(sudoku.board1[0][6] == 1);

    sudoku.unsetIndex(1, 3);
    sudoku.unsetIndex(2, 9);
    sudoku.unsetIndex(6, 1);

    testing.expect(sudoku.board1[0][1] == 0);
    testing.expect(sudoku.board1[0][2] == 0);
    testing.expect(sudoku.board1[0][6] == 0);
}

test "Set/Unset Indices" {
    var sudoku: @This() = .init();

    const indices = [_]u8{ 1, 2, 6 };
    const values = [_]u8{ 3, 9, 1 };

    sudoku.setIndices(&indices, &values);

    testing.expect(sudoku.board1[0][1] == 3);
    testing.expect(sudoku.board1[0][2] == 9);
    testing.expect(sudoku.board1[0][6] == 1);

    sudoku.unsetIndices(&indices, &values);
    testing.expect(sudoku.board1[0][1] == 0);
    testing.expect(sudoku.board1[0][2] == 0);
    testing.expect(sudoku.board1[0][6] == 0);
}

test "Set/Unset SubIndex" {
    var sudoku: @This() = .init();

    const subindices = [_]SubIndex{
        .{ .row = 0, .col = 1 },
        .{ .row = 0, .col = 2 },
        .{ .row = 0, .col = 6 },
    };
    const values = [_]u8{ 1, 2, 6 };

    for (subindices, values) |subindex, value|
        sudoku.setSubIndex(subindex, value);
    testing.expect(sudoku.board1[0][1] == 3);
    testing.expect(sudoku.board1[0][2] == 9);
    testing.expect(sudoku.board1[0][6] == 1);

    for (subindices, values) |subindex, value|
        sudoku.unsetSubIndex(subindex, value);
    testing.expect(sudoku.board1[0][1] == 0);
    testing.expect(sudoku.board1[0][2] == 0);
    testing.expect(sudoku.board1[0][6] == 0);
}

test "Set/Unset SubIndices" {
    var sudoku: @This() = .init();

    const subindices = [_]SubIndex{
        .{ .row = 0, .col = 1 },
        .{ .row = 0, .col = 2 },
        .{ .row = 0, .col = 6 },
    };
    const values = [_]u8{ 1, 2, 6 };
    sudoku.setSubIndices(&subindices, &values);

    testing.expect(sudoku.board1[0][1] == 3);
    testing.expect(sudoku.board1[0][2] == 9);
    testing.expect(sudoku.board1[0][6] == 1);

    sudoku.unsetSubIndices(&subindices, &values);

    testing.expect(sudoku.board1[0][1] == 0);
    testing.expect(sudoku.board1[0][2] == 0);
    testing.expect(sudoku.board1[0][6] == 0);
}
