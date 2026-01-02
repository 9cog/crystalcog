require "spec"
require "../../src/cogutil/randgen"

describe CogUtil::RandGen do
  describe "basic random generation" do
    it "generates random boolean values" do
      rng = CogUtil::RandGen.new(42_u32) # Fixed seed for reproducibility

      # Generate many booleans and check we get both true and false
      values = Array.new(100) { rng.randbool }
      values.should contain(true)
      values.should contain(false)
    end

    it "generates random integers in range" do
      rng = CogUtil::RandGen.new(42_u32)

      # Test single parameter version
      100.times do
        val = rng.randint(10)
        val.should be >= 0
        val.should be < 10
      end

      # Test two parameter version
      100.times do
        val = rng.randint(5, 15)
        val.should be >= 5
        val.should be < 15
      end
    end

    it "generates random floats in range" do
      rng = CogUtil::RandGen.new(42_u32)

      # Test basic float generation [0, 1)
      100.times do
        val = rng.randfloat
        val.should be >= 0.0
        val.should be < 1.0
      end

      # Test single parameter version [0, max)
      100.times do
        val = rng.randfloat(5.0)
        val.should be >= 0.0
        val.should be < 5.0
      end

      # Test two parameter version [min, max)
      100.times do
        val = rng.randfloat(2.0, 8.0)
        val.should be >= 2.0
        val.should be < 8.0
      end
    end

    it "generates normal distribution values" do
      rng = CogUtil::RandGen.new(42_u32)

      # Generate many values and check they approximate normal distribution
      values = Array.new(1000) { rng.randnormal(0.0, 1.0) }

      # Check mean is approximately 0
      mean = values.sum / values.size
      mean.abs.should be < 0.1

      # Check most values are within 3 standard deviations
      within_3_sigma = values.count { |v| v.abs < 3.0 }
      (within_3_sigma.to_f / values.size).should be > 0.99
    end
  end

  describe "array operations" do
    it "chooses random elements from array" do
      rng = CogUtil::RandGen.new(42_u32)
      array = [1, 2, 3, 4, 5]

      100.times do
        choice = rng.choose(array)
        array.should contain(choice)
      end
    end

    it "samples without replacement" do
      rng = CogUtil::RandGen.new(42_u32)
      array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      sample = rng.sample(array, 5)
      sample.size.should eq(5)
      sample.uniq.size.should eq(5) # No duplicates

      sample.each do |item|
        array.should contain(item)
      end
    end

    it "shuffles arrays" do
      rng = CogUtil::RandGen.new(42_u32)
      original = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

      # Test shuffle (returns new array)
      shuffled = rng.shuffle(original)
      shuffled.size.should eq(original.size)
      shuffled.sort.should eq(original.sort)

      # Test shuffle! (modifies in place)
      array_copy = original.dup
      rng.shuffle!(array_copy)
      array_copy.size.should eq(original.size)
      array_copy.sort.should eq(original.sort)
    end
  end

  describe "class methods" do
    it "provides static access to default generator" do
      # Seed for reproducibility
      CogUtil::RandGen.seed(42_u32)

      # Test that class methods work
      CogUtil::RandGen.randbool.should be_a(Bool)
      CogUtil::RandGen.randint(10).should be < 10
      CogUtil::RandGen.randfloat.should be < 1.0
      CogUtil::RandGen.randdouble.should be < 1.0

      val = CogUtil::RandGen.randnormal(0.0, 1.0)
      val.should be_a(Float64)

      array = [1, 2, 3, 4, 5]
      choice = CogUtil::RandGen.choose(array)
      array.should contain(choice)
    end
  end

  describe "module convenience methods" do
    it "provides global access methods" do
      # Test CogUtil module methods
      CogUtil.randbool.should be_a(Bool)
      CogUtil.randint(10).should be < 10
      CogUtil.randfloat.should be < 1.0
      CogUtil.randdouble.should be < 1.0
      CogUtil.randnormal(0.0, 1.0).should be_a(Float64)
    end
  end

  describe "byte generation" do
    it "generates random bytes" do
      rng = CogUtil::RandGen.new(42_u32)

      bytes = rng.randbytes(10)
      bytes.size.should eq(10)

      # Check that bytes are actually random by ensuring not all are the same
      bytes.to_a.uniq.size.should be > 1
    end
  end
end
