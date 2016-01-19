require "./frame"

# Allows creating a coordinate plane of cells, which can then be layered and #
# sent to termbox. This depends on termbox using the last cell for a given
# position, so that layers added later take precedence over initial layers.
#
module Minder
  class Buffer < Termbox::Element
    getter :layers

    @frame :: Frame

    def initialize(@width, @height, @pivot, @frame : Frame)
      @layers = [] of Layer
      @layers << Layer.new(width, height).new_transform(pivot.x, pivot.y)
    end

    def render
      cells = [] of Termbox::Cell
      previous_layer = nil
      @layers.each do |layer|
        layer.render.each do |cell|
          cells.reject! do |cell2|
            cell.position.x == cell2.position.x &&
              cell.position.y == cell2.position.y
          end
          cells << cell
        end
      end
      cells
    end

    def resize(width, height)
      @layers[0] = Layer.new(width, height).new_transform(@pivot.x, @pivot.y)
    end

    def apply(element)
      layer = Layer.build_from_element(element)
      @layers << layer
    end

    def pop
      @layers.pop
    end

    def print_to_file
      Dir.mkdir_p "screens"
      string = "#{@frame.class.name}\n"
      @layers.each_with_index do |layer, index|
        string += "layer ##{index}\n\n"
        string +=layer.grid.map do |row|
          row.map { |cell| cell.char }.join
        end.join("\n") + "\n"
      end
      File.write(
        "screens/#{@frame.class.name.underscore.downcase.gsub("minder::", "")}.txt",
        string)
    end
  end
end
