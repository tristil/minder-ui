module Minder
  class TasksScroller
    include Observer

    getter :cursor_y,
           :scroll_offset

    def initialize(@collection, @frame)
      @cursor_y = 0
      @scroll_offset = 0
      @collection.add_observer(self)
    end

    def height
      @frame.allocated_tasks_height
    end

    def tasks
      @collection.tasks[visible_tasks_range]
    end

    def update(event_name, change : Int32)
      if event_name == "changed"
        set_cursor_y(change)
      end
    end

    def set_cursor_y(change)
      if @collection.last_task_selected?
        @cursor_y = height
        @scroll_offset = @collection.selected_task_index - height
      elsif @collection.first_task_selected?
        @cursor_y = 0
        @scroll_offset = 0
      elsif @collection.position_from_last(1)
        @cursor_y = height - 1
        @scroll_offset = @collection.selected_task_index + 1 - height
      elsif moving_backward_and_scrolling?(change)
        @cursor_y = 2
        @scroll_offset -= 1 unless scroll_offset == 0
      elsif moving_forward_and_scrolling?(change)
        @cursor_y = height - 2
        @scroll_offset += 1
      else
        @cursor_y += change
      end
    end

    def visible_tasks_range
      (scroll_offset..(height + scroll_offset))
    end

    def moving_backward_and_scrolling?(change)
      @cursor_y < 3 &&
        scroll_offset > 0 &&
        change < 0
    end

    def moving_forward_and_scrolling?(change)
      (height - @cursor_y) < 3 &&
        (@collection.selected_task_index + 3) >= height &&
        change > 0
    end
  end
end
