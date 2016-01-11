class Cursor < Termbox::Element
  property :position

  def initialize(x, y)
    @position = Termbox::Position.new(x, y)
  end

  def render
    cell = Termbox::Cell.new(
      ' ',
      @position,
      Termbox::COLOR_BLACK,
      Termbox::COLOR_WHITE)
    [cell]
  end
end
