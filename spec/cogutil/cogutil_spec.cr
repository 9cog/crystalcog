require "spec"
require "../../src/cogutil/cogutil"

describe CogUtil do
  describe "module initialization" do
    it "initializes CogUtil module" do
      CogUtil.initialize
      # Should not crash
    end

    it "has correct version" do
      CogUtil::VERSION.should eq("0.1.0")
    end

    it "provides logging functionality" do
      CogUtil::Logger.should be_truthy
    end

    it "provides configuration functionality" do
      CogUtil::Config.should be_truthy
    end

    it "provides random number generation" do
      CogUtil::RandGen.should be_truthy
    end
  end

  describe "utility functions" do
    it "provides timestamp functionality" do
      timestamp = CogUtil.timestamp
      timestamp.should be_a(String)
      timestamp.size.should be > 0
    end

    it "provides string utilities" do
      result = CogUtil.to_string("test")
      result.should eq("test")
    end
  end

  describe "integration" do
    it "works with other modules" do
      CogUtil.initialize

      # Should be able to create logger
      logger = CogUtil::Logger.new("test")
      logger.should_not be_nil

      # Should be able to use config
      config = CogUtil::Config.new
      config.should_not be_nil
    end
  end
end
