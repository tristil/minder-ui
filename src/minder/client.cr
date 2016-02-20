module Minder
  class Client
    include Observer

    def initialize
      @socket = UNIXSocket.new(SOCKET_LOCATION)
    end

    def update(event_name, data)
    end

    def tasks
      @socket.puts("GET /tasks\n")
      data = @socket.gets("END\n").to_s.gsub("END\n", "")
      JSON.parse(data).as_a
    end

    def add_task(description)
      @socket.puts("POST /tasks: #{description}\n")
    end

    def disconnect
      @socket.close
    end
  end
end
