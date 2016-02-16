module Minder
  class Task
    getter :description

    def initialize(data)
      Minder.debug(data)
      @description = (data as Hash)["description"] as String
    end
  end
end
