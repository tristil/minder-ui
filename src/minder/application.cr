require "../libs/termbox"

module Minder
  class Application
    getter :logger

    def run
      Minder.logger.warn "Start"

      window = Termbox::Window.new

      scene = Scene.new(window)

      pomodoro_frame = Minder::PomodoroFrame.new(
        window: window,
        height: 5)
      scene << pomodoro_frame

      tasks_frame = Minder::TasksFrame.new(
        window: window,
        display_mode: DisplayMode::Expands)
      scene << tasks_frame

      quick_add_frame = Minder::QuickAddFrame.new(
        window: window,
        height: 3)
      scene << quick_add_frame

      # Reset things
      window.clear

      scene.draw

      loop do
        ev = window.peek(1)
        if ev.type == Termbox::EVENT_KEY
          if [Termbox::KEY_CTRL_C, Termbox::KEY_CTRL_D].includes? ev.key
            break
          end
        elsif ev.type == Termbox::EVENT_RESIZE
          Minder.logger.warn "repaint_all"
          scene.repaint_all
        end

        scene.draw

        sleep(0.01)
      end

      at_exit do
        window.shutdown
      end
    end
  end
end
