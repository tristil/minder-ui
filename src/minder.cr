require "logger"
require "./observer"
require "./observable"
require "../libs/termbox"
require "./termbox"

module Minder
  alias Row = Array(Termbox::Cell)
  alias Grid = Array(Row)

  enum DisplayMode
    Fixed
    Expands
  end

  LOGGER_FILE = File.expand_path(File.dirname(__FILE__) + "/../info.log")
  SOCKET_LOCATION = "#{ENV["HOME"]}/.minder-test/minder.sock"

  @@logger = Logger.new(File.open(LOGGER_FILE, "a+"))
  @@logger.level = Logger::DEBUG
  @@logger_channel = Channel(String)

  def self.debug(string)
    @@logger.debug(string)
  end
end

require "./minder/*"
