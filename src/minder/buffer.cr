require "./frame"

# Allows creating a coordinate plane of cells, which can then be layered and #
# sent to termbox. This depends on termbox using the last cell for a given
# position, so that layers added later take precedence over initial layers.
#
module Minder
  class Buffer < Termbox::Element
    @frame :: Frame

    def initialize(@width, @height, @pivot, @frame : Frame)
      @layers = [] of Layer
      @layers << Layer.new(width, height).new_transform(pivot.x, pivot.y)
    end

    def render
      @layers.flat_map do |layer|
        layer.render
      end
    end

    def apply(element)
      layer = Layer.build_from_element(element)
      @layers << layer
    end

    def print_to_file
      string = "#{@frame.class.name}"
      @layers.each_with_index do |layer, index|
        string += "layer ##{index}\n\n"
        string +=layer.grid.map do |row|
          row.map { |cell| cell.char }.join
        end.join("\n") + "\n"
      end
      File.write(
        "#{@frame.class.name.underscore.downcase.gsub("minder::", "")}.txt",
        string)
    end
  end
end
