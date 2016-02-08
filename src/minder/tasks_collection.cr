module Minder
  class TasksCollection
    include Observable(Observer)

    delegate :size,
             "empty?", @tasks

    getter :tasks,
           :selected_task_index

    def initialize(@tasks = [] of Hash(String, JSON::Type))
      @last_selected_task_index = @selected_task_index = 0
    end

    def select_next_task
      return if selected_task_index == tasks.size - 1
      self.selected_task_index += 1
    end

    def select_previous_task
      return if selected_task_index == 0
      self.selected_task_index -= 1
    end

    def select_first_task
      self.selected_task_index = 0
    end

    def select_last_task
      self.selected_task_index = @tasks.size - 1
    end

    def selected_task_index=(number)
      @last_selected_task_index = @selected_task_index
      @selected_task_index = number
      notify_observers(@selected_task_index - @last_selected_task_index)
    end

    def first_task_selected?
      selected_task_index  == 0
    end

    def last_task_selected?
      selected_task_index == size - 1
    end

    def position_from_last(num)
      selected_task_index == size - 1 - num
    end

    def moving_forward?
    end

    def moving_backward?
    end
  end
end
