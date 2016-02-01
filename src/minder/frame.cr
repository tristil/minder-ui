require "./cursor"
require "../libs/termbox"

module Minder
  class Frame
    property :focused

    getter :window,
           :min_height,
           :height,
           :width,
           :left,
           :top,
           :lines,
           :container,
           :buffer,
           :cursor_moved,
           :changed,
           :display_mode

    delegate "pivot=", @container
    delegate "fixed?", "expands?", @display_mode

    @cursor_x :: Int32
    @cursor_y :: Int32

    @container :: Termbox::Container

    def initialize(@window = null,
                   @height = 3,
                   @width = 40,
                   @top = 0,
                   @left = 0,
                   @display_mode = DisplayMode::Fixed,
                   @collection = TasksCollection.new)
      @cursor_x = 1
      @cursor_y = 1
      @focused = false
      @hidden = false
      @has_cursor = false
      @changed :: Bool
      @changed = true
      @cursor_moved = true

      pivot = Termbox::Position.new(0, top)

      @buffer = Buffer.new(@width, @height, pivot, (self as Frame))

      @container = Termbox::Container.new(
        Termbox::Position.new(0, top),
        width,
        height)
      @border = Termbox::Border.new(container)
      @container << @border

      @lines = [] of String
      @min_height = height
    end

    def handle_key(key)
    end

    def pivot=(pivot)
      @container.pivot = pivot
      @buffer.pivot = pivot
    end

    def resize
      @buffer.resize(@width, @height)
    end

    def contents
      [] of String
    end

    def repaint
      @changed = true
    end

    def changed?
      @changed
    end

    def cursor_moved?
      @cursor_moved
    end

    def render
      return unless @changed

      if fixed? && contents.size > height - 2
        self.height = contents.size + 2
      end

      @container.elements.reject! do |cell|
        cell.is_a?(Termbox::Cell)
      end
      write_lines(contents)

      @buffer.pop unless @buffer.layers.size == 1
      @buffer.apply(@container)

      Thread.new { @buffer.print_to_file }
      @changed = false
    end

    def position_cursor
      window.cursor(Termbox::Position.new(@cursor_x, @cursor_y + top))
    end

    def width=(number)
      return if number == @width

      @changed = true
      @buffer.width = number
      @container.width = number
      @border.width = number
      @width = number
    end

    def height=(number)
      return if number == @height

      @changed = true
      @height = number
      container.height = number
      @buffer.height = number
      @border.height = number
    end

    def write_lines(lines)
      @lines = lines
      lines.each_with_index do |line, index|
        write_string(Termbox::Position.new(0, index), line)
      end
    end

    def write_string(position, string)
      x, y = position.x, position.y
      string.each_char do |char|
        cell = Termbox::Cell.new(
          char,
          Termbox::Position.new(x + 1, y + 1)
        )
        container << cell
        x += 1
      end
    end

    def focus
      @focused = true
      @has_cursor = true
    end

    def unfocus
      @focused = false
      @has_cursor = false
    end

    def focused?
      @focused
    end

    def hidden?
      @hidden
    end

    def hide
      erase
      @hidden = true
    end

    def unhide
      @hidden = false
    end

    def has_cursor?
      @has_cursor
    end
  end
end
