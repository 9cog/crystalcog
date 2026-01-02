# Crystal implementation of OpenCog Logger
# Converted from cogutil/opencog/util/Logger.h and Logger.cc
#
# This provides a comprehensive logging system for the Crystal OpenCog implementation.

require "log"
require "colorize"

module CogUtil
  # Log levels for OpenCog logging system
  enum LogLevel
    NONE  = 0
    ERROR = 1
    WARN  = 2
    INFO  = 3
    DEBUG = 4
    FINE  = 5

    # Convert from string to enum (case insensitive)
    def self.from_string(str : String) : LogLevel
      case str.downcase
      when "none"            then NONE
      when "error"           then ERROR
      when "warn", "warning" then WARN
      when "info"            then INFO
      when "debug"           then DEBUG
      when "fine"            then FINE
      else
        raise ArgumentError.new("Invalid log level: #{str}")
      end
    end

    # Convert to string representation
    def to_s(io : IO) : Nil
      io << case self
      when NONE  then "NONE"
      when ERROR then "ERROR"
      when WARN  then "WARN"
      when INFO  then "INFO"
      when DEBUG then "DEBUG"
      when FINE  then "FINE"
      end
    end

    # Get color for console output
    def color
      case self
      when ERROR then :red
      when WARN  then :yellow
      when INFO  then :cyan
      when DEBUG then :light_gray
      when FINE  then :dark_gray
      else            :default
      end
    end
  end

  # Main Logger class - Crystal implementation of OpenCog Logger
  class Logger
    property level : LogLevel
    property timestamp_enabled : Bool
    property filename : String?

    @file : File?
    @mutex : Mutex

    # Class-level default logger
    @@default_logger : Logger?

    def initialize(@filename : String? = nil,
                   @level : LogLevel = LogLevel::INFO,
                   @timestamp_enabled : Bool = true)
      @mutex = Mutex.new

      # Open file if filename provided
      if filename = @filename
        @file = File.open(filename, "a")
      end
    end

    # Cleanup file handle
    def finalize
      @file.try(&.close)
    end

    # Set log level from string
    def set_level(level_str : String)
      @level = LogLevel.from_string(level_str)
    end

    # Set log level directly
    def set_level(@level : LogLevel)
    end

    # Check if a level would be logged
    def would_log?(level : LogLevel) : Bool
      level.value <= @level.value
    end

    # Core logging method
    def log(level : LogLevel, message : String, source : String? = nil)
      return unless would_log?(level)

      @mutex.synchronize do
        formatted_message = format_message(level, message, source)

        # Write to file if configured
        if file = @file
          file.puts(formatted_message)
          file.flush
        end

        # Write to console with color
        case level
        when .error?
          STDERR.puts(formatted_message.colorize(level.color))
        else
          STDOUT.puts(formatted_message.colorize(level.color))
        end
      end
    end

    # Convenience methods for different log levels
    def error(message : String, source : String? = nil)
      log(LogLevel::ERROR, message, source)
    end

    def warn(message : String, source : String? = nil)
      log(LogLevel::WARN, message, source)
    end

    def info(message : String, source : String? = nil)
      log(LogLevel::INFO, message, source)
    end

    def debug(message : String, source : String? = nil)
      log(LogLevel::DEBUG, message, source)
    end

    def fine(message : String, source : String? = nil)
      log(LogLevel::FINE, message, source)
    end

    # Printf-style logging methods
    def error(format : String, *args)
      error(sprintf(format, *args))
    end

    def warn(format : String, *args)
      warn(sprintf(format, *args))
    end

    def info(format : String, *args)
      info(sprintf(format, *args))
    end

    def debug(format : String, *args)
      debug(sprintf(format, *args))
    end

    def fine(format : String, *args)
      fine(sprintf(format, *args))
    end

    # Format log message with timestamp and level
    private def format_message(level : LogLevel, message : String, source : String?) : String
      parts = [] of String

      # Add timestamp if enabled
      if @timestamp_enabled
        parts << Time.local.to_s("%Y-%m-%d %H:%M:%S.%3N")
      end

      # Add log level
      parts << "[#{level}]"

      # Add source if provided
      if source
        parts << "[#{source}]"
      end

      # Add the actual message
      parts << message

      parts.join(" ")
    end

    # Class methods for default logger
    def self.default_logger
      @@default_logger ||= Logger.new("opencog.log")
    end

    def self.set_default_logger(logger : Logger)
      @@default_logger = logger
    end

    # Global logging methods using default logger
    def self.error(message : String, source : String? = nil)
      default_logger.error(message, source)
    end

    def self.warn(message : String, source : String? = nil)
      default_logger.warn(message, source)
    end

    def self.info(message : String, source : String? = nil)
      default_logger.info(message, source)
    end

    def self.debug(message : String, source : String? = nil)
      default_logger.debug(message, source)
    end

    def self.fine(message : String, source : String? = nil)
      default_logger.fine(message, source)
    end

    # Set global log level
    def self.set_level(level : LogLevel)
      default_logger.level = level
    end

    def self.set_level(level_str : String)
      default_logger.set_level(level_str)
    end
  end

  # Macro for easy source location in logs
  macro log_with_source(level, message)
    {% source_location = "#{__FILE__}:#{__LINE__}" %}
    CogUtil::Logger.{{level.id}}({{message}}, {{source_location}})
  end
end
