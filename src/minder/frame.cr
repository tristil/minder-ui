require "../libs/termbox"

module Minder
  class Frame
    getter :window,
           :min_height,
           :height,
           :width,
           :left,
           :top,
           :lines,
           :container,
           :changed,
           :display_mode

    delegate "pivot=", @container
    delegate "fixed?", "expands?", @display_mode

    @container :: Termbox::Container

    def initialize(@window = null,
                   @height = 3,
                   @width = 40,
                   @top = 0,
                   @left = 0,
                   @display_mode = DisplayMode::Fixed)
      @focused = false
      @hidden = false
      @has_cursor = false
      @changed :: Bool
      @changed = true

      @container = Termbox::Container.new(
        Termbox::Position.new(0, top),
        window.width,
        height)
      @border = Termbox::Border.new(container)
      @container << @border

      @lines = [] of String
      @min_height = height
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

    def render
      return unless @changed

      if fixed? && contents.size > height - 2
        self.height = contents.size + 2
      end

      clear

      write_lines(contents)

      @changed = false
    end

    def clear
      Minder.logger.debug "clear"
      (1...height).each do |y|
        (1...width).each do |x|
          existing_cell = container.elements.find do |element|
            next unless element.is_a?(Termbox::Cell)

            element.position.x == x && element.position.y == y
          end

          if existing_cell
            existing_cell = existing_cell as Termbox::Cell
            # if x == 1
              # Minder.logger.debug "height: #{height} y: #{existing_cell.position.y}"
            # end

            if y >= height - 1 || x >= width - 1
              Minder.logger.debug "Removing #{existing_cell}"
              container.elements.reject! { |element| element == existing_cell }
            else
              (existing_cell as Termbox::Cell).char = ' ' # self.class.name[-7]
            end
          else
            unless y >= height - 1 || x >= width - 1
              new_cell = Termbox::Cell.new(' ', Termbox::Position.new(x, y))
              container.elements << new_cell
            end
          end
        end
      end
    end

    def width=(number)
      return if number == @width

      @changed = true
      @container.width = number
      @border.width = number
      @width = number
    end

    def height=(number)
      return if number == @height

      @changed = true
      @height = number
      container.height = number
      @border.height = number
    end

    def write_lines(lines)
      @lines = lines
      Minder.logger.debug "(#{self.class.name}) #{lines.inspect}"
      lines.each_with_index do |line, index|
        Minder.logger.debug "(#{self.class.name}) line: #{index}"
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
        if x == 0
          Minder.logger.debug "(#{self.class.name}) #{cell.position}"
        end

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
