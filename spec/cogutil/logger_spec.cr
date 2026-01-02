require "spec"
require "../../src/cogutil/logger"

describe CogUtil::Logger do
  describe "LogLevel" do
    it "converts from string correctly" do
      CogUtil::LogLevel.from_string("error").should eq(CogUtil::LogLevel::ERROR)
      CogUtil::LogLevel.from_string("ERROR").should eq(CogUtil::LogLevel::ERROR)
      CogUtil::LogLevel.from_string("warn").should eq(CogUtil::LogLevel::WARN)
      CogUtil::LogLevel.from_string("warning").should eq(CogUtil::LogLevel::WARN)
      CogUtil::LogLevel.from_string("info").should eq(CogUtil::LogLevel::INFO)
      CogUtil::LogLevel.from_string("debug").should eq(CogUtil::LogLevel::DEBUG)
      CogUtil::LogLevel.from_string("fine").should eq(CogUtil::LogLevel::FINE)
      CogUtil::LogLevel.from_string("none").should eq(CogUtil::LogLevel::NONE)
    end

    it "raises exception for invalid level" do
      expect_raises(ArgumentError) do
        CogUtil::LogLevel.from_string("invalid")
      end
    end

    it "converts to string correctly" do
      CogUtil::LogLevel::ERROR.to_s.should eq("ERROR")
      CogUtil::LogLevel::WARN.to_s.should eq("WARN")
      CogUtil::LogLevel::INFO.to_s.should eq("INFO")
      CogUtil::LogLevel::DEBUG.to_s.should eq("DEBUG")
      CogUtil::LogLevel::FINE.to_s.should eq("FINE")
      CogUtil::LogLevel::NONE.to_s.should eq("NONE")
    end
  end

  describe "Logger instance" do
    it "creates logger with default settings" do
      logger = CogUtil::Logger.new
      logger.level.should eq(CogUtil::LogLevel::INFO)
      logger.timestamp_enabled.should be_true
    end

    it "creates logger with custom settings" do
      logger = CogUtil::Logger.new("test.log", CogUtil::LogLevel::DEBUG, false)
      logger.level.should eq(CogUtil::LogLevel::DEBUG)
      logger.timestamp_enabled.should be_false
      logger.filename.should eq("test.log")
    end

    it "sets level correctly" do
      logger = CogUtil::Logger.new
      logger.set_level(CogUtil::LogLevel::ERROR)
      logger.level.should eq(CogUtil::LogLevel::ERROR)

      logger.set_level("debug")
      logger.level.should eq(CogUtil::LogLevel::DEBUG)
    end

    it "checks would_log correctly" do
      logger = CogUtil::Logger.new(level: CogUtil::LogLevel::WARN)
      logger.would_log?(CogUtil::LogLevel::ERROR).should be_true
      logger.would_log?(CogUtil::LogLevel::WARN).should be_true
      logger.would_log?(CogUtil::LogLevel::INFO).should be_false
      logger.would_log?(CogUtil::LogLevel::DEBUG).should be_false
    end

    it "logs messages correctly" do
      # Test that logging doesn't crash - actual output testing would require
      # capturing stdout/stderr which is complex in this simple test
      logger = CogUtil::Logger.new
      logger.error("Test error message")
      logger.warn("Test warning message")
      logger.info("Test info message")
      logger.debug("Test debug message")
      logger.fine("Test fine message")
    end
  end

  describe "global logging methods" do
    it "provides global access to default logger" do
      # These should not crash
      CogUtil::Logger.error("Global error")
      CogUtil::Logger.warn("Global warning")
      CogUtil::Logger.info("Global info")
      CogUtil::Logger.debug("Global debug")
      CogUtil::Logger.fine("Global fine")
    end

    it "sets global log level" do
      CogUtil::Logger.set_level(CogUtil::LogLevel::ERROR)
      CogUtil::Logger.default_logger.level.should eq(CogUtil::LogLevel::ERROR)

      CogUtil::Logger.set_level("info")
      CogUtil::Logger.default_logger.level.should eq(CogUtil::LogLevel::INFO)
    end
  end
end
