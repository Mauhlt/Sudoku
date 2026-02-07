const std = @import("std");
const Sudoku = @import("Sudoku.zig");
const ind2sub = @import("Sudoku.zig").indexToSubIndex;

pub fn main() !void {
    var sudoku: Sudoku = .init();

    // fill in first row
    for (0..9) |i| {
        for (0..9) |j| {
            if (i == j) continue;
            sudoku.unsetIndex(@truncate(i), @truncate(i));
        }
    }
    // fill in first col
    for (0..9) |i| {
        const sub = ind2sub(i * 9 + 0);
        sudoku.unsetSubIndex(sub, @truncate(i));
    }
    // fill in last block
    const start_col: usize = 6;
    const start_row: usize = 6;
    for (0..3) |i| {
        for (0..3) |j| {
            for (0..9) |k| {
                sudoku.unsetSubIndex(sub, @truncate(k));
            }
        }
    }

    // set first col
    sudoku.print();
    sudoku.printPossibities();
}
