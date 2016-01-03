require "logger"
require "./minder/*"

module Minder
  enum DisplayMode
    Fixed
    Expands
  end

  LOGGER_FILE = File.expand_path(File.dirname(__FILE__) + "/../info.log")

  @@logger = Logger.new(File.open(LOGGER_FILE, "a+"))
  @@logger.level = Logger::DEBUG

  def self.logger
    @@logger
  end
end
