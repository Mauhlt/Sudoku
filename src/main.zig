const std = @import("std");
const Sudoku = @import("Sudoku.zig");

pub fn main() !void {
    const sudoku: Sudoku = .init();
    sudoku.print();
    sudoku.printPossibities();
}
