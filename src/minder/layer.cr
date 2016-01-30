module Minder
  class Layer
    @@id = 0

    getter :height,
           :width,
           :grid,
           :element

    @grid :: Grid

    def self.build_from_element(element)
      layer = new(element.width, element.height, element.pivot)
      element.render.each do |cell|
        adjusted_y = cell.position.y - element.pivot.y
        adjusted_x = cell.position.x - element.pivot.x
        layer.grid[adjusted_y][adjusted_x] = cell
      end
      layer
    end

    def initialize(@width : Int32, @height : Int32, pivot = nil)
      @@id +=1
      @grid = Grid.new(@height)
      build_matrix(pivot)
    end

    def initialize(matrix : Grid)
      @@id +=1
      @grid = matrix
      @width = matrix[0].size
      @height = matrix.size
    end

    def set(x, y, cell)
      @grid[y][x] = cell
    end

    def render
      @grid.flatten
    end

    def build_matrix(pivot = nil)
      pivot ||= Termbox::Position.new(0, 0)
      height.times do |y|
        @grid << Row.new(width)
        width.times do |x|
          position = Termbox::Position.new(x + pivot.x , y + pivot.y)
          @grid[y] << Termbox::Cell.new(' ', position)
        end
      end
    end
  end
end
