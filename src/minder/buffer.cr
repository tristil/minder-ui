module Minder
  alias Row = Array(Termbox::Cell)

  class Layer
    def initialize(width, height)
      @matrix = Array(Row).new(height)
      height.times do |y|
        @matrix << Row.new(width)
        width.times do |x|
          @matrix[y] << Termbox::Cell.new(' ', Termbox::Position.new(x, y))
        end
      end
    end

    def set(x, y, cell)
      #Minder.logger.warn @matrix
      #Minder.logger.warn cell
      @matrix[y][x] = cell if @matrix[y]? && @matrix[y][x]?
    end

    def fill(cell, top, left, height, width)
      @matrix
    end

    def render
      @matrix.flatten
    end
  end

  class Buffer < Termbox::Element
    def initialize(width, height)
      @width = width
      @height = height
      @layers = [] of Layer
      @layers << Layer.new(width, height)
    end

    def render
      @layers.flat_map do |layer|
        layer.render
      end
    end

    def apply(element)
      layer = Layer.new(@width, @height)
      element.render.each do |cell|
        layer.set(cell.position.x, cell.position.y, cell)
      end
      @layers << layer
    end
  end
end
