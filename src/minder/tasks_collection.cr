module Minder
  class TasksCollection
    delegate :size,
             "empty?", @tasks

    getter :tasks,
           :selected_task_index

    def initialize(@tasks = [] of Hash(String, JSON::Type))
      @selected_task_index = 0
    end

    def select_next_task
      @selected_task_index += 1 unless @selected_task_index == tasks.size - 1
    end

    def select_previous_task
      @selected_task_index -= 1 unless @selected_task_index == 0
    end

    def select_first_task
      @selected_task_index = 0
    end

    def select_last_task
      @selected_task_index = @tasks.size - 1
    end
  end
end
