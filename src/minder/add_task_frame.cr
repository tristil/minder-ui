require "./frame"

module Minder
  class AddTaskFrame < Frame
    INTRO_TEXT = "Add task: "
    @text_editor = TextEditor.new

    def contents
      ["#{INTRO_TEXT}#{@text_editor.text}"]
    end

    def initial_cursor_x
      contents[0].size + 1
    end

    def handle_key(event)
      @text_editor.handle_key(event)
    end

    def after_initialize
      @text_editor.add_observer(self)
    end

    def update(event_name, text)
      @changed = true
      @cursor_x = @text_editor.cursor_x + INTRO_TEXT.size + 1
      if event_name == "submitted"
        @collection.add_task(text)
      end
    end
  end
end
