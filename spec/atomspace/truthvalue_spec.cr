require "spec"
require "../../src/atomspace/truthvalue"

describe AtomSpace::TruthValue do
  describe "SimpleTruthValue" do
    it "creates valid truth values" do
      tv = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv.strength.should eq(0.8)
      tv.confidence.should eq(0.9)
      tv.valid?.should be_true
    end

    it "rejects invalid truth values" do
      expect_raises(ArgumentError) do
        AtomSpace::SimpleTruthValue.new(-0.1, 0.5)
      end

      expect_raises(ArgumentError) do
        AtomSpace::SimpleTruthValue.new(0.5, 1.1)
      end
    end

    it "converts confidence to count" do
      tv = AtomSpace::SimpleTruthValue.new(0.8, 0.8)
      tv.count.should be_close(4.0, 0.001) # 0.8 / (1 - 0.8) = 4
    end

    it "checks for special values" do
      true_tv = AtomSpace::SimpleTruthValue.new(1.0, 1.0)
      false_tv = AtomSpace::SimpleTruthValue.new(0.0, 1.0)
      null_tv = AtomSpace::SimpleTruthValue.new(0.0, 0.0)

      true_tv.true?.should be_true
      false_tv.false?.should be_true
      null_tv.null?.should be_true
    end

    it "merges truth values correctly" do
      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.6)
      tv2 = AtomSpace::SimpleTruthValue.new(0.7, 0.4)

      merged = tv1.merge(tv2)

      # Weighted average: (0.8*0.6 + 0.7*0.4) / (0.6 + 0.4) = 0.76
      merged.strength.should be_close(0.76, 0.01)
      merged.confidence.should eq(1.0) # Capped at 1.0
    end

    it "converts to and from string" do
      tv = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv.to_s.should eq("(0.8, 0.9)")

      parsed = AtomSpace::TruthValue.from_string("(0.8, 0.9)")
      parsed.should be_a(AtomSpace::SimpleTruthValue)
      parsed.strength.should eq(0.8)
      parsed.confidence.should eq(0.9)
    end
  end

  describe "CountTruthValue" do
    it "creates valid count truth values" do
      tv = AtomSpace::CountTruthValue.new(0.8, 0.9, 10.0)
      tv.strength.should eq(0.8)
      tv.confidence.should eq(0.9)
      tv.count.should eq(10.0)
    end

    it "merges count truth values" do
      tv1 = AtomSpace::CountTruthValue.new(0.8, 0.6, 5.0)
      tv2 = AtomSpace::CountTruthValue.new(0.6, 0.4, 3.0)

      merged = tv1.merge(tv2)
      merged.should be_a(AtomSpace::CountTruthValue)

      # New count should be sum: 5 + 3 = 8
      merged.count.should eq(8.0)

      # New strength should be weighted average: (0.8*5 + 0.6*3) / 8 = 0.725
      merged.strength.should be_close(0.725, 0.01)
    end
  end

  describe "IndefiniteTruthValue" do
    it "creates valid indefinite truth values" do
      tv = AtomSpace::IndefiniteTruthValue.new(0.3, 0.8, 0.9)
      tv.lower.should eq(0.3)
      tv.upper.should eq(0.8)
      tv.confidence.should eq(0.9)
      tv.strength.should eq(0.55) # (0.3 + 0.8) / 2
    end

    it "rejects invalid bounds" do
      expect_raises(ArgumentError) do
        AtomSpace::IndefiniteTruthValue.new(0.8, 0.3) # lower > upper
      end
    end

    it "merges indefinite truth values" do
      tv1 = AtomSpace::IndefiniteTruthValue.new(0.2, 0.6, 0.5)
      tv2 = AtomSpace::IndefiniteTruthValue.new(0.4, 0.8, 0.5)

      merged = tv1.merge(tv2)
      merged.should be_a(AtomSpace::IndefiniteTruthValue)

      # Intersection should be [0.4, 0.6]
      merged.as(AtomSpace::IndefiniteTruthValue).lower.should eq(0.4)
      merged.as(AtomSpace::IndefiniteTruthValue).upper.should eq(0.6)
    end
  end

  describe "FuzzyTruthValue" do
    it "creates valid fuzzy truth values" do
      tv = AtomSpace::FuzzyTruthValue.new(0.8, 0.9, 0.1)
      tv.strength.should eq(0.8)
      tv.confidence.should eq(0.9)
      tv.uncertainty.should eq(0.1)
    end

    it "merges fuzzy truth values" do
      tv1 = AtomSpace::FuzzyTruthValue.new(0.8, 0.6, 0.1)
      tv2 = AtomSpace::FuzzyTruthValue.new(0.7, 0.4, 0.2)

      merged = tv1.merge(tv2)
      merged.should be_a(AtomSpace::FuzzyTruthValue)

      # Uncertainty should combine: sqrt(0.1^2 + 0.2^2) ≈ 0.224
      merged.as(AtomSpace::FuzzyTruthValue).uncertainty.should be_close(0.224, 0.01)
    end
  end

  describe "TruthValueUtil" do
    it "performs logical AND correctly" do
      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv2 = AtomSpace::SimpleTruthValue.new(0.6, 0.7)

      result = AtomSpace::TruthValueUtil.and_tv(tv1, tv2)

      # AND: strength = 0.8 * 0.6 = 0.48, confidence = 0.9 * 0.7 = 0.63
      result.strength.should eq(0.48)
      result.confidence.should eq(0.63)
    end

    it "performs logical OR correctly" do
      tv1 = AtomSpace::SimpleTruthValue.new(0.6, 0.8)
      tv2 = AtomSpace::SimpleTruthValue.new(0.4, 0.7)

      result = AtomSpace::TruthValueUtil.or_tv(tv1, tv2)

      # OR: strength = 0.6 + 0.4 - 0.6*0.4 = 0.76
      result.strength.should eq(0.76)
      result.confidence.should be_close(0.56, 0.001) # 0.8 * 0.7
    end

    it "performs logical NOT correctly" do
      tv = AtomSpace::SimpleTruthValue.new(0.8, 0.9)

      result = AtomSpace::TruthValueUtil.not_tv(tv)

      # NOT: strength = 1 - 0.8 = 0.2, confidence unchanged
      result.strength.should be_close(0.2, 0.001)
      result.confidence.should eq(0.9)
    end

    it "performs implication correctly" do
      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv2 = AtomSpace::SimpleTruthValue.new(0.6, 0.7)

      result = AtomSpace::TruthValueUtil.implies_tv(tv1, tv2)

      # Implication is ¬A ∨ B
      # ¬A = (0.2, 0.9), B = (0.6, 0.7)
      # ¬A ∨ B = 0.2 + 0.6 - 0.2*0.6 = 0.68
      result.strength.should be_close(0.68, 0.001)
    end
  end

  describe "default truth values" do
    it "provides standard default values" do
      AtomSpace::TruthValue::DEFAULT_TV.strength.should eq(1.0)
      AtomSpace::TruthValue::DEFAULT_TV.confidence.should eq(0.0)

      AtomSpace::TruthValue::TRUE_TV.strength.should eq(1.0)
      AtomSpace::TruthValue::TRUE_TV.confidence.should eq(1.0)

      AtomSpace::TruthValue::FALSE_TV.strength.should eq(0.0)
      AtomSpace::TruthValue::FALSE_TV.confidence.should eq(1.0)

      AtomSpace::TruthValue::NULL_TV.strength.should eq(0.0)
      AtomSpace::TruthValue::NULL_TV.confidence.should eq(0.0)
    end
  end
end
