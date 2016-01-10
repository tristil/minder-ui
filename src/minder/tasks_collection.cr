class TasksCollection
  delegate "empty?", @tasks

  getter :tasks

  def initialize(tasks)
    @tasks = tasks.as_a
  end
end
