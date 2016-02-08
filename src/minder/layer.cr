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
        layer.set(adjusted_x, adjusted_y, cell)
      end
      layer
    end

    def initialize(@width : Int32, @height : Int32, pivot = nil, fill_with = nil)
      @@id +=1
      @grid = Grid.new(@height)
      # Minder.debug("#{@@id}: #{@grid.object_id}")
      build_matrix(pivot, fill_with)
    end

    def initialize(matrix : Grid)
      @@id +=1
      @grid = matrix
      @width = matrix[0].size
      @height = matrix.size
    end

    def get(x, y)
      @grid[y][x]
    end

    def set(x, y, cell)
      return unless @grid[y]?
      return unless @grid[y][x]?
      @grid[y][x] = Termbox::Cell.new(cell.char, cell.position)
    end

    def render
      @grid.flatten
    end

    def build_matrix(pivot = nil, fill_with = ' ')
      pivot ||= Termbox::Position.new(0, 0)
      height.times do |y|
        @grid << Row.new(width)
        #if fill_with
          width.times do |x|
            position = Termbox::Position.new(x + pivot.x , y + pivot.y)
            @grid[y] << Termbox::Cell.new(' ', position)
          end
        #end
      end
    end
  end
end
