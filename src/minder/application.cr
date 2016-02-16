require "socket"
require "json"

module Minder
  class Application
    getter :logger

    def run
      Minder.debug "Start"

      socket = UNIXSocket.new(SOCKET_LOCATION)
      socket.puts("tasks\n")
      data = socket.gets("END\n").to_s.gsub("END\n", "")
      data = JSON.parse(data)
      tasks_collection = TasksCollection.new(data.as_a)

      window = Termbox::Window.new
      scene = Scene.new(window)
      pomodoro_frame = PomodoroFrame.new(
        window: window,
        height: 5,
        top: 0,
        width: window.width)
      scene << pomodoro_frame
      tasks_frame = TasksFrame.new(
        window: window,
        width: window.width,
        top: 5,
        collection: tasks_collection,
        display_mode: DisplayMode::Expands)
      scene << tasks_frame
      add_task_frame = AddTaskFrame.new(
        window: window,
        height: 3,
        width: window.width,
        collection: tasks_collection
      )
      scene << add_task_frame
      # Reset things
      window.clear

      scene.focus_frame(tasks_frame)
      scene.draw

      spawn do
        loop do
          ev = window.poll
          if ev.type == Termbox::EVENT_KEY
            if [Termbox::KEY_CTRL_C, Termbox::KEY_CTRL_D].includes? ev.key
              exit
            elsif ev.key == Termbox::KEY_TAB
              scene.switch_focus
            else
              #Minder.debug("Focused frame: #{scene.focused_frame.class.name}")
              scene.focused_frame.handle_key(ev)
              #Minder.debug("fiber loop: scene changed? #{scene.changed?}")
            end
          elsif ev.type == Termbox::EVENT_RESIZE
            scene.repaint_all
          end
          sleep 0.001
        end
      end

      loop do
        #Minder.debug("main loop: scene changed? #{scene.changed?}")
        scene.draw
        sleep(0.001)
      end

      at_exit do
        window.clear
        socket.close
        window.shutdown
        puts "Shutdown"
      end
    end
  end
end
