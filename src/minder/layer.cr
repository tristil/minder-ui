module Minder
  class Layer
    getter :height,
           :width,
           :grid,
           :element

    @grid :: Grid

    def self.build_from_element(element)
      layer = new(element.width, element.height)
        .new_transform(element.pivot.x, element.pivot.y)
      element.render.each do |cell|
        next unless layer.grid[cell.position.y]?
        next unless layer.grid[cell.position.y][cell.position.x]?
        layer.grid[cell.position.y][cell.position.x] = cell
      end
      layer
    end

    def initialize(@width : Int32, @height : Int32)
      @grid = Grid.new(@height)
      build_matrix
    end

    def initialize(matrix : Grid)
      @grid = matrix
      @width = matrix[0].size
      @height = matrix.size
    end

    def new_transform(x, y)
      matrix = @grid.clone
      height.times do |y|
        width.times do |x|
          matrix[y][x] = matrix[y][x].new_transform(x, y)
        end
      end
      self.class.new(matrix)
    end

    def set(x, y, cell)
      @grid[y][x] = cell if @grid[y]? && @grid[y][x]?
    end

    def render
      @grid.flatten
    end

    def build_matrix
      height.times do |y|
        @grid << Row.new(width)
        width.times do |x|
          @grid[y] << Termbox::Cell.new(' ', Termbox::Position.new(x, y))
        end
      end
    end
  end
end
