# Crystal implementation of OpenCog Config
# Converted from cogutil/opencog/util/Config.h and Config.cc
#
# This provides configuration management for the Crystal OpenCog implementation.

require "yaml"
require "json"
require "./logger"

module CogUtil
  # Configuration manager for OpenCog
  # Supports YAML, JSON, and simple key=value format files
  class Config
    @table : Hash(String, String)
    @config_loaded : Bool
    @config_path : String?
    @config_filename : String

    # Singleton instance
    @@instance : Config?

    def initialize(@config_filename : String = "opencog.conf")
      @table = Hash(String, String).new
      @config_loaded = false
      @config_path = nil

      # Try to load configuration file
      load_config
      setup_logger
    end

    # Singleton access
    def self.instance
      @@instance ||= Config.new
    end

    def self.create_instance(filename : String = "opencog.conf")
      @@instance = Config.new(filename)
    end

    # Load configuration from file
    def load_config
      # Search paths for config file
      search_paths = [
        ".",
        "./config",
        ENV["HOME"]? ? ENV["HOME"] + "/.opencog" : nil,
        "/etc/opencog",
        "/usr/local/etc/opencog",
      ].compact

      search_paths.each do |path|
        config_file = File.join(path, @config_filename)

        if File.exists?(config_file)
          @config_path = path
          load_config_file(config_file)
          @config_loaded = true
          Logger.info("Loaded configuration from: #{config_file}")
          return
        end
      end

      Logger.warn("No configuration file found. Using defaults.")
    end

    # Load configuration from specific file
    private def load_config_file(filepath : String)
      content = File.read(filepath)

      case File.extname(filepath).downcase
      when ".yaml", ".yml"
        load_yaml_config(content)
      when ".json"
        load_json_config(content)
      else
        load_simple_config(content)
      end
    rescue ex
      Logger.error("Failed to load config file #{filepath}: #{ex.message}")
    end

    # Load YAML configuration
    private def load_yaml_config(content : String)
      yaml = YAML.parse(content)
      flatten_yaml(yaml, @table)
    end

    # Load JSON configuration
    private def load_json_config(content : String)
      json = JSON.parse(content)
      flatten_json(json, @table)
    end

    # Load simple key=value configuration
    private def load_simple_config(content : String)
      content.each_line do |line|
        line = line.strip
        next if line.empty? || line.starts_with?('#')

        if match = line.match(/^(\w+)\s*=\s*(.*)$/)
          key = match[1]
          value = match[2].gsub(/^["']|["']$/, "") # Remove quotes
          @table[key] = value
        end
      end
    end

    # Flatten YAML structure into dot-notation keys
    private def flatten_yaml(node, target : Hash(String, String), prefix : String = "")
      case node
      when Hash
        node.each do |key, value|
          new_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
          flatten_yaml(value, target, new_key)
        end
      when Array
        node.each_with_index do |value, index|
          new_key = "#{prefix}.#{index}"
          flatten_yaml(value, target, new_key)
        end
      else
        target[prefix] = node.to_s
      end
    end

    # Flatten JSON structure into dot-notation keys
    private def flatten_json(node, target : Hash(String, String), prefix : String = "")
      case node
      when Hash
        node.each do |key, value|
          new_key = prefix.empty? ? key : "#{prefix}.#{key}"
          flatten_json(value, target, new_key)
        end
      when Array
        node.each_with_index do |value, index|
          new_key = "#{prefix}.#{index}"
          flatten_json(value, target, new_key)
        end
      else
        target[prefix] = node.to_s
      end
    end

    # Get configuration value as string
    def get(key : String, default : String = "") : String
      @table.fetch(key, default)
    end

    # Get configuration value as specific types
    def get_bool(key : String, default : Bool = false) : Bool
      value = @table[key]?
      return default unless value

      case value.downcase
      when "true", "yes", "1", "on"  then true
      when "false", "no", "0", "off" then false
      else                                default
      end
    rescue
      default
    end

    def get_int(key : String, default : Int32 = 0) : Int32
      value = @table[key]?
      return default unless value
      value.to_i32? || default
    end

    def get_float(key : String, default : Float64 = 0.0) : Float64
      value = @table[key]?
      return default unless value
      value.to_f64? || default
    end

    # Set configuration value
    def set(key : String, value : String)
      @table[key] = value
    end

    def set(key : String, value)
      @table[key] = value.to_s
    end

    # Check if key exists
    def has?(key : String) : Bool
      @table.has_key?(key)
    end

    # Get all keys
    def keys : Array(String)
      @table.keys.to_a
    end

    # Clear all configuration
    def clear
      @table.clear
    end

    # Get configuration as hash
    def to_h : Hash(String, String)
      @table.dup
    end

    # Save configuration to file
    def save(filepath : String)
      case File.extname(filepath).downcase
      when ".yaml", ".yml"
        save_yaml(filepath)
      when ".json"
        save_json(filepath)
      else
        save_simple(filepath)
      end
    end

    # Save as YAML format
    private def save_yaml(filepath : String)
      File.open(filepath, "w") do |file|
        @table.to_yaml(file)
      end
    end

    # Save as JSON format
    private def save_json(filepath : String)
      File.open(filepath, "w") do |file|
        @table.to_json(file)
      end
    end

    # Save as simple key=value format
    private def save_simple(filepath : String)
      File.open(filepath, "w") do |file|
        @table.each do |key, value|
          file.puts("#{key}=#{value}")
        end
      end
    end

    # Setup logger based on configuration
    private def setup_logger
      # Set log level if configured
      if log_level = @table["LOG_LEVEL"]?
        Logger.set_level(log_level)
      end

      # Set log file if configured
      if log_file = @table["LOG_FILE"]?
        logger = Logger.new(log_file)
        Logger.set_default_logger(logger)
      end
    end

    # Configuration shortcuts for common OpenCog settings
    module Shortcuts
      def self.atomspace_storage_type
        Config.instance.get("STORAGE_TYPE", "memory")
      end

      def self.atomspace_storage_url
        Config.instance.get("STORAGE_URL", "")
      end

      def self.cogserver_port
        Config.instance.get_int("COGSERVER_PORT", 17001)
      end

      def self.cogserver_host
        Config.instance.get("COGSERVER_HOST", "localhost")
      end

      def self.log_level
        Config.instance.get("LOG_LEVEL", "INFO")
      end

      def self.enable_persistence?
        Config.instance.get_bool("ENABLE_PERSISTENCE", false)
      end

      def self.enable_attention?
        Config.instance.get_bool("ENABLE_ATTENTION", true)
      end
    end
  end

  # Global configuration access methods
  def self.config
    Config.instance
  end

  def self.config_get(key : String, default : String = "")
    Config.instance.get(key, default)
  end

  def self.config_set(key : String, value)
    Config.instance.set(key, value)
  end
end
