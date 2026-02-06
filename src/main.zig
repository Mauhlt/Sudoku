const std = @import("std");
const Sudoku = @import("Sudoku.zig");

pub fn main() !void {
    var sudoku: Sudoku = .init();
    for (0..9) |i| {
        sudoku.setIndex(@truncate(i), @truncate(i));
    }
    sudoku.print();
    sudoku.printPossibities();
}
