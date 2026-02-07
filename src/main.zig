const std = @import("std");
const Sudoku = @import("Sudoku.zig");
const ind2sub = @import("Sudoku.zig").indexToSubIndex;

pub fn main() !void {
    var sudoku: Sudoku = .init();

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
    sudoku.printPossibities();
    sudoku.print();

    const is_row = sudoku.isRowSolved(1);
    const is_col = sudoku.isColSolved(4);
    const is_block = sudoku.isBlockSolved(8);
    std.debug.print("Row: {}\n", .{is_row});
    std.debug.print("Col: {}\n", .{is_col});
    std.debug.print("Block: {}\n", .{is_block});

    sudoku.printCollisions();
}
