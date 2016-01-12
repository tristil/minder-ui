# Allows creating a coordinate plane of cells, which can then be layered and #
# sent to termbox. This depends on termbox using the last cell for a given
# position, so that layers added later take precedence over initial layers.
#
module Minder
  alias Row = Array(Termbox::Cell)
  alias Matrix = Array(Row)

  class Layer
    getter :height,
           :width

    def initialize(@width : Int32, @height : Int32)
      @matrix = Matrix.new(height)
      height.times do |y|
        @matrix << Row.new(width)
        width.times do |x|
          @matrix[y] << Termbox::Cell.new(' ', Termbox::Position.new(x, y))
        end
      end
    end

    def initialize(matrix : Matrix)
      @matrix = matrix
      @width = matrix[0].size
      @height = matrix.size
    end

    def new_transform(x, y)
      matrix = @matrix.clone
      height.times do |y|
        width.times do |x|
          matrix[y][x] = matrix[y][x].new_transform(x, y)
        end
      end
      self.class.new(matrix)
    end

    def set(x, y, cell)
      @matrix[y][x] = cell if @matrix[y]? && @matrix[y][x]?
    end

    def render
      @matrix.flatten
    end
  end

  class Buffer < Termbox::Element
    def initialize(width, height, pivot)
      @width = width
      @height = height
      @layers = [] of (Layer|Termbox::Element)
      @layers << Layer.new(width, height).new_transform(pivot.x, pivot.y)
      @pivot = pivot
    end

    def render
      @layers.flat_map do |layer|
        layer.render
      end
    end

    def apply(element)
      @layers << element
    end
  end
end
