require "./frame"

module Minder
  class PomodoroFrame < Frame
    @running = false

    def contents
      if running?
        running_message
      else
        pending_message
      end
    end

    def pending_message
      ["Press space to start new period"]
    end

    def running_message
      ["Work period",
        " ",
        "00:32 (out of 25:00)"]
    end

    def running?
      @running
    end

    def template
      text = <<-TEXT
<%= period.title %>  #{pomodoros}
TEXT

      if period.message
        text += <<-TEXT

<%= period.message %>
TEXT
      end

      if task_manager.started_task
        text += <<-TEXT

Working on: #{task_manager.started_task}
TEXT
      end

      text
    end

    def period
      pomodoro_runner.current_period
    end

    def handle_char_keypress(key)
      event = case key
      when ' ' then :continue
      end

      changed
      notify_observers(event)
    end

    def handle_non_char_keypress(key)
      event = case key
      when 3 then :exit
      end

      changed
      notify_observers(event)
    end

    def pomodoros
      pomodoro_runner.pomodoros_today.map do |pomodoro|
        "#{pomodoro_runner.emoji} "
      end.join
    end
  end
end
