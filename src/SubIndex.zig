row: usize,
col: usize,

pub fn toIndex(self: *const @This()) usize {
    return self.row * 9 + self.col;
}
