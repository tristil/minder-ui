require "../libs/termbox"

module Minder
  class Scene
    getter :frames,
           :window

    def initialize(@window)
      @frames = [] of Frame
    end

    def <<(frame)
      @frames << frame
      @window << frame.buffer
    end

    def repaint_all
      @frames.each { |frame| frame.repaint }
      @changed = true
    end

    def draw
      resize
      @frames.each(&.render)
      window.render
    end

    def fixed_frames
      @frames.select(&.fixed?)
    end

    def focus_frame(frame)
      puts frame
      @frames.each do |search_frame|
        if search_frame == frame
          search_frame.focused = true
        else
          search_frame.focused = false
        end
      end
    end

    def focused_frame
      @frames.find(&.focused) || raise "No frame focused"
    end

    def fixed_frames_height
      fixed_frames.sum(&.height)
    end

    def changed?
      @frames.any?(&.changed?)
    end

    def resize
      #Minder.logger.warn "resize"
      line = 0
      @frames.each do |frame|
        frame.pivot = Termbox::Position.new(0, line)
        frame.width = window.width
        if frame.expands?
          frame.pivot = Termbox::Position.new(0, line)
          frame.height = window.height - fixed_frames_height
        end
        #Minder.logger.warn "resize #{frame.class.name} height: #{frame.height}, line: #{line}"
        line += frame.height
      end
    end
  end
end
