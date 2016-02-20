module Minder
  class TextEditor
    include Observable(AddTaskFrame)

    getter :cursor_x

    @cursor_x = 0

    delegate :pop, @text_buffer
    @text_buffer = [] of Char

    def handle_key(event)
      return unless event.type == Termbox::EVENT_KEY
      Minder.debug(event)

      if Termbox::DELETE_KEYS.includes?(event.key)
        return if @text_buffer.empty?
        @text_buffer.pop
        @cursor_x -= 1
        notify_observers("changed", text)
      elsif Termbox::ARROW_KEYS.includes?(event.key)

      elsif [Termbox::KEY_ENTER].includes?(event.key)
        @cursor_x = 0
        notify_observers("submitted", text)
        @text_buffer.clear
      elsif [0, Termbox::KEY_SPACE].includes?(event.key)
        handle_char_keypress(event)
      end
    end

    def handle_char_keypress(event)
      @text_buffer << event.ch.chr
      @cursor_x += 1
      notify_observers("changed", text)
    end

    def text
      @text_buffer.join("")
    end
  end
end
