module Minder
  class TasksCollection
    include Observable(Observer)

    delegate :size,
             "empty?", @tasks

    getter :tasks,
           :selected_task_index

    @tasks = [] of Task

    def initialize(tasks = [] of Hash(String, String))
      tasks.each { |task| @tasks << Task.new(task) }

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
      notify_observers("changed", @selected_task_index - @last_selected_task_index)
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

    def add_task(text)
      @tasks << Task.new({"description" => text})
      notify_observers("added", text)
    end
  end
end
