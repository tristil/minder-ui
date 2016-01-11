require "./frame"

module Minder
  class TasksFrame < Frame
    getter :selected_row,
           :task_editor

    def initialize(@window = null,
                   @height = 3,
                   @width = 40,
                   @top = 0,
                   @left = 0,
                   @display_mode = DisplayMode::Fixed,
                   @collection = nil)
      super
      @cursor_x = 3
      @cursor_y = 3
      @selected_task_index = 0
    end

    def contents
      if @minimized
        minimized_message
      elsif (@collection as TasksCollection).empty?
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

    def tasks_to_display
      (@collection as TasksCollection).tasks[0..tasks_height]
    end

    def task_rows
      tasks_to_display.map { |task| task_row(task) }
    end

    def task_row(task)
      task = task as Hash(String, JSON::Type)
      description = task["description"] as String
      "-[ ] #{description}"
    end

    def empty_text
      ["Add a task by tabbing to Quick add task below."]
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
      height - header_text_lines.length - 3
    end

    def offset_tasks_text
      tasks_text_lines[visible_tasks_range].join("\n")
    end

    def visible_tasks_range
      (scroll_offset..(allocated_tasks_height + scroll_offset - 1))
    end

    def total_tasks_height
      task_manager.tasks.length
    end

    def scroll_offset
      position = task_manager.selected_task_index + 1
      if position > allocated_tasks_height
        position - allocated_tasks_height
      else
        0
      end
    end

    def handle_key(key)
      handle_char_keypress(key)
    end

    def handle_task_editor_event(event, data = {} of Symbol => String)
      if event == :stop_editing
        @editing = false
        @task_editor = nil
      elsif event == :update_task
        task_manager.update_task(task_manager.selected_task, data)
        @editing = false
        @task_editor = nil
      end

      changed
      notify_observers(event)
    end

    def handle_char_keypress(key_event)
      Minder.logger.warn(key_event) unless key_event.ch == 0
      event =
        case key_event.ch
        when 'j' then :select_next_task
        when 'k' then :select_previous_task
        when 'd' then :complete_task
        when 'x' then :delete_task
        when 's' then :start_task
        when 'u' then :unstart_task
        when 'G' then :select_last_task
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
          # @keypress_memory ||= [] of Char
          # @keypress_memory << 'g'
          # if @keypress_memory == ['g', 'g']
            # @keypress_memory = [] of Char
            # :select_first_task
          # end
        when ' '
          # if minimized?
            # unminimize
            # :redraw
          # end
        end

      case event
      when :select_next_task
        @selected_task_index += 1
        move_cursor
        @changed = true
      when :select_previous_task
        @selected_task_index -= 1 unless @selected_task_index == 0
        move_cursor
        @changed = true
      end
    end

    def move_cursor
      @cursor_y = 3 + @selected_task_index
    end
  end
end
