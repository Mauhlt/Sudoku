const std = @import("std");
const testing = std.testing;
const assert = std.debug.assert;
const SubIndex = @import("SubIndex.zig");

/// Sum of a row/col/block
const COMPLETED_NUM = 0b111111111;

/// Solves sudoku board automatically
/// 1. sets up board with values
/// 2. checks if setup is a valid initial setup
///
/// Board:
/// board1:
/// - bit board of all possible values
/// - eliminate possible values as game goes on
/// - use printPossibilities to visualize
/// board2:
/// - defaults to 255
/// - contains final value for position
/// - use print to visualize
board1: [9][9]u16,
board2: [9][9]u8,

/// Initializes board
pub fn init() @This() {
    return @This(){
        .board1 = @bitCast(@as(@Vector(81, u16), @splat(COMPLETED_NUM))),
        .board2 = @bitCast(@as(@Vector(81, u8), @splat(std.math.maxInt(u8)))),
    };
}

/// Sets possibilities board to include that value
pub fn setIndex(self: *@This(), index: u8, value: u8) void {
    assert(value < 9);
    assert(index < 81);
    const sub = indexToSubIndex(index);
    self.board1[sub.row][sub.col] |= @as(u16, 1) << @truncate(value);
}

/// Sets possibilities board to have that value
pub fn setIndices(self: *@This(), indices: []u8, values: []u8) void {
    assert(values.len == indices.len);
    assert(values.len < 81);
    for (values, indices) |value, index|
        self.setIndex(value, index);
}

/// Sets value at subindex in possibilities board
pub fn setSubIndex(self: *@This(), subIndex: SubIndex, value: u8) void {
    assert(value < 9);
    assert(subIndex.row < 9 and subIndex.col < 9);
    self.board1[subIndex.row][subIndex.col] |= @as(u16, 1) << @truncate(value);
}

/// Sets value at subindices in possibilities board
pub fn setSubIndices(self: *@This(), subIndices: []SubIndex, values: []u8) void {
    assert(values.len == subIndices.len);
    assert(values.len < 81);
    for (values, subIndices) |value, subIndex| {
        self.setSubIndex(value, subIndex);
    }
}

/// Unsets value from index in possibilities board
pub fn unsetIndex(self: *@This(), index: u8, value: u8) void {
    assert(value < 9);
    assert(index < 81);
    const subIndex = indexToSubIndex(index);
    self.board1[subIndex.row][subIndex.col] &= (@as(u16, 1) << @truncate(value));
}

/// Unsets value from indices in possibilities board
pub fn unsetIndices(self: *@This(), indices: []u8, values: []u8) void {
    assert(values.len == indices.len);
    for (values, indices) |value, index|
        self.unsetIndex(value, index);
}

/// Unsets value from subindex in possibilities board
pub fn unsetSubIndex(self: *@This(), subIndex: SubIndex, value: u8) void {
    assert(value < 9);
    assert(subIndex.row < 9 and subIndex.col < 9);
    self.board1[subIndex.row][subIndex.col] &= @as(u16, 1) << @truncate(value);
}

/// Unsets value from subindices in possibilities board
pub fn unsetSubIndices(self: *@This(), subIndices: []u8, values: []u8) void {
    assert(values.len == subIndices.len);
    for (values, subIndices) |value, subIndex|
        self.unsetSubIndex(value, subIndex);
}

/// Sets index in possibilities board and solution board to this value
pub fn assignIndex(self: *@This(), index: usize, value: u8) void {
    const sub = indexToSubIndex(index);
    self.assignSubIndex(sub, value);
}

/// Sets indices in possibilities board and solution board to this value
pub fn assignIndices(self: *@This(), indices: []usize, values: []u8) void {
    assert(indices.len == values.len);
    for (indices, values) |index, value|
        self.assignIndex(index, value);
}

/// Sets subindex in possibilities board and solution board to this value
pub fn assignSubIndex(self: *@This(), subindex: SubIndex, value: u8) void {
    assert(subindex.row < 9 and subindex.col < 9);
    assert(value < 9);
    self.board1[subindex.row][subindex.col] = 0;
    self.setSubIndex(subindex, value);
    self.board2[subindex.row][subindex.col] = value;
}

/// Sets subindices in possibilities board and solution board to this value
pub fn assignSubIndices(self: *@This(), subindices: []SubIndex, values: []u8) void {
    assert(subindices.len == values.len);
    for (subindices, values) |subindex, value|
        self.assignSubIndex(subindex, value);
}

pub fn solve(self: *@This()) !void {
    // Check that board is a valid starting position:
    // 1. no rows or cols or blocks have duplicate values
    for (0..9) |i| {
        if (self.hasRowCollision(i)) {
            std.debug.print("Row Collision on {}\n", .{i});
            return error.RowCollision;
        }
        if (self.hasColCollision(i)) return error.ColCollision;
        if (self.hasBlockCollision(i)) return error.BlockCollision;
    }

    // const v: @Vector(81, u8) = @splat(0);
    // var i: usize = 0;
    // while (@reduce(.Or, @as(@Vector(81, u8), self.board) == v)) : (i += 1) {
    //     if (i > 10) break;
    //     self.print();
    // }

    // Step 1: Loop through each number
    // Step 2: Check if numbers form a limited possibility
    // Step 3: Record single possibilities to solution board
}

pub fn isRowSolved(self: *const @This(), row: usize) bool {
    assert(row < 9);
    var num: usize = 0;
    inline for (0..9) |i|
        num |= self.board1[row][i];
    return num == COMPLETED_NUM;
}

pub fn isColSolved(self: *const @This(), col: usize) bool {
    assert(col < 9);
    var num: usize = 0;
    inline for (0..9) |i|
        num |= self.board1[i][col];

    return num == COMPLETED_NUM;
}

pub fn isBlockSolved(self: *const @This(), block: usize) bool {
    assert(block < 9);
    var sum: usize = 0;
    const start_row: usize = (block / 3);
    const start_col: usize = block % 3;
    inline for (0..3) |r| {
        inline for (0..3) |c| {
            sum |= self.board1[start_row * 3 + r][start_col * 3 + c];
        }
    }
    std.debug.print("{}\n", .{sum});
    return sum == COMPLETED_NUM;
}

pub fn printPossibilities(self: *const @This()) void {
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
            if (col < 255)
                std.debug.print("{c} ", .{col + '0'})
            else
                std.debug.print("0 ", .{});
        }
        std.debug.print("\n", .{});
    }
    std.debug.print("\n", .{});
}

fn hasRowCollision(self: *const @This(), row: usize) bool {
    assert(row < 9);
    for (0..8) |i| {
        if (self.board1[row][i] == COMPLETED_NUM) continue;
        for (i + 1..9) |j| {
            if (self.board1[row][j] == COMPLETED_NUM) continue;
            if (self.board1[row][i] == self.board1[row][j]) {
                std.debug.print("{}x{} - {}x{}: {b}\n", .{ row, i, row, j, self.board1[row][i] });
                return true;
            }
        }
    }
    return false;
}

fn hasColCollision(self: *const @This(), col: usize) bool {
    assert(col < 9);
    for (0..8) |i| {
        if (self.board1[i][col] == COMPLETED_NUM) continue;
        for (i + 1..9) |j| {
            if (self.board1[i][col] == COMPLETED_NUM) continue;
            if (self.board1[i][col] == self.board1[j][col]) {
                std.debug.print("{}x{} - {}x{}: {b}\n", .{ i, col, j, col, self.board1[i][col] });
                return true;
            }
        }
    }
    return false;
}

fn hasBlockCollision(self: *const @This(), block: usize) bool {
    assert(block < 9);
    const start_row = (block / 3) * 3;
    const start_col = (block % 3) * 3;
    for (0..2) |i| {
        for (0..2) |j| {
            for (i + 1..3) |k| {
                for (j + 1..3) |l| {
                    if (self.board1[start_row + i][start_col + j] == self.board1[start_row + k][start_col + l])
                        return true;
                }
            }
        }
    }
    return false;
}

pub fn printCollisions(self: *const @This()) void {
    for (0..8) |i| {
        for (0..8) |j| {
            if (@popCount(self.board1[i][j]) != 1) continue;
            // check row for duplicates
            for (j + 1..9) |k| {
                if (self.board1[i][k] == self.board1[i][j]) {
                    std.debug.print("Row Collision: {}x{} matches {}x{}: {}\n", .{ i, j, i, k, self.board1[i][j] });
                }
            }

            // check col for duplicates
            for (i + 1..9) |k| {
                if (self.board1[i][j] == self.board1[k][j]) {
                    std.debug.print("Col Collision: {}x{} matches {}x{}: {}\n", .{ i, j, k, j, self.board1[i][j] });
                }
            }

            // check block for duplicates
            const start_row = (i / 3) * 3;
            const start_col = (j / 3) * 3;
            for (1..9) |k| {
                const row = start_row + k / 3;
                const col = start_col + k % 3;
                if (i == row and j == col) continue;
                if (row < i and col < j) continue;
                if (self.board1[i][j] == self.board1[row][col]) {
                    std.debug.print("Block Collision: {}x{} matches {}x{}: {}\n", .{ i, j, row, col, self.board1[i][j] });
                }
            }
        }
    }
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

test "Is Row/Col/Block Complete" {
    var sudoku: @This() = .init();

    for (0..9) |i| {
        var curr: usize = i;
        for (0..9) |j| {
            if (curr == 9) {
                curr = 0;
            }
            sudoku.board1[i][j] = @as(u16, 1) << @truncate(curr);
            curr += 1;
        }
    }

    // convert possibilities to solo values if popcount == 1
    for (0..9) |i| {
        for (0..9) |j| {
            if (@popCount(sudoku.board1[i][j]) == 1) {
                sudoku.board2[i][j] = @ctz(sudoku.board1[i][j]) + 1;
            }
        }
    }

    // set first col
    // sudoku.printPossibities();
    // sudoku.print();

    const is_row = sudoku.isRowSolved(1);
    const is_col = sudoku.isColSolved(4);
    const is_block = sudoku.isBlockSolved(8);

    try testing.expect(is_row == true);
    try testing.expect(is_col == true);
    try testing.expect(is_block == false);
}
