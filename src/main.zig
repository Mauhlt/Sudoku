const std = @import("std");
const Sudoku = @import("Sudoku.zig");
const ind2sub = @import("Sudoku.zig").indexToSubIndex;

pub fn main() !void {
    var sudoku: Sudoku = .init();

    sudoku.print();
    sudoku.setSubIndex(.{ .row = 0, .col = 2 }, 6);
    sudoku.setSubIndex(.{ .row = 0, .col = 3 }, 7);
    sudoku.setSubIndex(.{ .row = 0, .col = 5 }, 2);
    sudoku.setSubIndex(.{ .row = 0, .col = 7 }, 1);
    sudoku.setSubIndex(.{ .row = 0, .col = 8 }, 8);

    sudoku.setSubIndex(.{ .row = 1, .col = 0 }, 7);
    sudoku.setSubIndex(.{ .row = 1, .col = 1 }, 8);
    sudoku.setSubIndex(.{ .row = 1, .col = 2 }, 1);
    sudoku.setSubIndex(.{ .row = 1, .col = 5 }, 4);
    sudoku.setSubIndex(.{ .row = 1, .col = 6 }, 2);

    sudoku.setSubIndex(.{ .row = 2, .col = 0 }, 1);
    sudoku.setSubIndex(.{ .row = 2, .col = 2 }, 2);
    sudoku.setSubIndex(.{ .row = 2, .col = 4 }, 6);
    sudoku.setSubIndex(.{ .row = 2, .col = 5 }, 8);
    sudoku.setSubIndex(.{ .row = 2, .col = 7 }, 7);

    sudoku.setSubIndex(.{ .row = 3, .col = 1 }, 7);
    sudoku.setSubIndex(.{ .row = 3, .col = 3 }, 5);
    sudoku.setSubIndex(.{ .row = 3, .col = 4 }, 4);
    sudoku.setSubIndex(.{ .row = 3, .col = 5 }, 1);
    sudoku.setSubIndex(.{ .row = 3, .col = 8 }, 2);

    sudoku.setSubIndex(.{ .row = 4, .col = 0 }, 6);
    sudoku.setSubIndex(.{ .row = 4, .col = 1 }, 1);
    sudoku.setSubIndex(.{ .row = 4, .col = 5 }, 8);

    sudoku.setSubIndex(.{ .row = 5, .col = 0 }, 1);
    sudoku.setSubIndex(.{ .row = 5, .col = 1 }, 7);
    sudoku.setSubIndex(.{ .row = 5, .col = 5 }, 5);

    sudoku.setSubIndex(.{ .row = 6, .col = 2 }, 7);
    sudoku.setSubIndex(.{ .row = 6, .col = 3 }, 3);
    sudoku.setSubIndex(.{ .row = 6, .col = 5 }, 1);
    sudoku.setSubIndex(.{ .row = 6, .col = 6 }, 5);
    sudoku.setSubIndex(.{ .row = 6, .col = 7 }, 0);

    sudoku.setSubIndex(.{ .row = 7, .col = 0 }, 1);
    sudoku.setSubIndex(.{ .row = 7, .col = 4 }, 0);
    sudoku.setSubIndex(.{ .row = 7, .col = 7 }, 8);
    sudoku.setSubIndex(.{ .row = 7, .col = 8 }, 7);

    sudoku.setSubIndex(.{ .row = 8, .col = 1 }, 4);
    sudoku.setSubIndex(.{ .row = 8, .col = 2 }, 0);
    sudoku.setSubIndex(.{ .row = 8, .col = 8 }, 1);

    sudoku.print();
    sudoku.printPossibilities();
}
