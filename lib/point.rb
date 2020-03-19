Point = Struct.new(:row, :column, keyword_init: true) do
  def +(other)
    self.class.new(row: row + other.row, column: column + other.column)
  end
end
