require "./frame"

module Minder
  class TasksFrame < Frame
    getter :selected_row,
           :task_editor

    @collection : Minder::TasksCollection

    def initialize(@window = null,
                   @height = 3,
                   @width = 40,
                   @top = 0,
                   @left = 0,
                   @display_mode = DisplayMode::Fixed,
                   @collection = TasksCollection.new)
      super
      @cursor_x = 3
      @keypress_memory = [] of Char
      @scroller = TasksScroller.new(@collection, (self as TasksFrame))
      @cursor_y = @scroller.cursor_y + 3
      @collection.add_observer(self)
    end

    def contents
      if @minimized
        minimized_message
      elsif @collection.empty?
        empty_text
      else
        tasks_text
      end
    end

    def tasks_text
      header_text + task_rows
    end

    def tasks_height
      @height - header_text.size - 3
    end

    def task_rows
      Minder.debug(@scroller.tasks)
      @scroller.tasks.map { |task| task_row(task) }
    end

    def task_row(task)
      description = task.description
      description = description[0..(width - 8)]
      "-[ ] #{description}"
    end

    def empty_text
      ["Add a task by tabbing to Add task below."]
    end

    def minimize
      @minimized = true
    end

    def unminimize
      @minimized = false
      self.height = desired_height
    end

    def minimized?
      @minimized
    end

    def editing?
      @editing
    end

    def minimized_message
      ["Space to see tasks"]
    end

    def header_text
      ["Tasks         ? to see commands",
       ""]
    end

    def allocated_tasks_height
      height - header_text.size - 3
    end

    def handle_key(key)
      handle_char_keypress(key)
    end

    def handle_char_keypress(key_event)
      Minder.debug("keypress: ch: #{key_event.ch}") unless key_event.ch == 0
      case key_event.ch
      when 'j'
        @collection.select_next_task
        move_cursor(1)
      when 'k' then :select_previous_task
        @collection.select_previous_task
        move_cursor(-1)
      when 'd' then :complete_task
      when 'x' then :delete_task
      when 's' then :start_task
      when 'u' then :unstart_task
      when 'G' then :select_last_task
        @collection.select_last_task
        move_cursor(:last)
      when 'e'
        # @editing = true
        # @task_editor = TaskEditor.new(task_manager.selected_task, self)
        # @task_editor.add_observer(self, :handle_task_editor_event)
        # :edit_task
      when '?' then :help
      when '/' then :search
      when 'm'
        # minimize
        # :redraw
      when 'n' then :next_search
      when 'N' then :previous_search
      when 'f' then :open_filter
      when 'g'
        @keypress_memory << 'g'
        if @keypress_memory == ['g', 'g']
          @keypress_memory = [] of Char
          @collection.select_first_task
          move_cursor(:first)
        end
      when ' '
        # if minimized?
          # unminimize
          # :redraw
        # end
      end
    end

    def move_cursor(change)
      @cursor_moved = true
      @cursor_y = @scroller.cursor_y + 3
      @changed = true
    end

    def update(event_name, data)
      @changed = true if event_name == "added"
    end
  end
end
