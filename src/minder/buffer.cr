require "./frame"

# Allows creating a coordinate plane of cells, which can then be layered and #
# sent to termbox. This depends on termbox using the last cell for a given
# position, so that layers added later take precedence over initial layers.
#
module Minder
  class Buffer < Termbox::Element
    property :height, :width, :pivot

    getter :layers

    @frame : Frame

    def initialize(@width, @height, @pivot, @frame : Frame)
      @layers = [] of Layer
      base_layer = Layer.new(width, height, pivot, ' ')
      @layers << base_layer
      #@last_rendered = base_layer
    end

    def combined_layer
      combined = Layer.new(width, height, pivot)
      @layers.each_with_index do |layer, index|
        #Minder.debug("[#{@frame.class.name}] Layer #{index}: #{layer.object_id}")
        layer.render.each do |cell|
          combined.set(
            cell.position.x - pivot.x,
            cell.position.y - pivot.y,
            cell)
        end
      end
      combined
    end

    def render
      combined_layer.render.reduce([] of Termbox::Cell) do |array, cell|
        # previous_cell = @last_rendered.get(
          # cell.position.x - pivot.x,
          # cell.position.y - pivot.y)

        # if cell.char == previous_cell.char
          # Minder.debug "#{cell.position} #{cell.char} == #{previous_cell.char}"
          # next array
        # end
        array << cell
        array
      end
    end

    def resize(width, height)
      @width = width
      @height = height
      @layers[0] = Layer.new(width, height, pivot)
    end

    def apply(element)
      layer = Layer.build_from_element(element)
      # Minder.debug("[#{@frame.class.name}] #{layer.object_id}")
      @layers << layer
    end

    def pop
      @layers.pop
    end

    def output_layer(layer)
      layer.grid.map do |row|
        row.map { |cell| cell.char }.join
      end.join("\n") + "\n"
    end

    def print_to_file
      Dir.mkdir_p "screens"
      string = "#{@frame.class.name}\n"
      @layers.each_with_index do |layer, index|
        string += "layer ##{index}\n\n"
        string += output_layer(layer)
      end

      string += "Combined layer\n\n"
      string += output_layer(combined_layer)

      cells = render
      string += "\nbuffer\n\n"
      line = 0
      cells.each do |cell|
        if cell.position.y != line
          line = cell.position.y
          string += "\n"
        else
          if cell.char == ' '
            string += ' '
          else
            string += cell.char
          end
        end
      end

      File.write(
        "screens/#{@frame.class.name.underscore.downcase.gsub("minder::", "")}.txt",
        string)
    end
  end
end
