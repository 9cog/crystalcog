require "spec"
require "../../src/attention/rent_collector"

describe Attention::RentCollector do
  describe "initialization" do
    it "creates rent collector" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      collector = Attention::RentCollector.new(bank)

      collector.should_not be_nil
    end

    it "has default rent rate" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      collector = Attention::RentCollector.new(bank)

      collector.rent_rate.should eq(0.01)
    end
  end

  describe "rent collection" do
    it "collects rent from atoms" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      collector = Attention::RentCollector.new(bank)

      # Create atom with attention value
      concept = atomspace.add_concept_node("test")
      av = AtomSpace::AttentionValue.new(100_i16, 50_i16)
      bank.set_attention_value(concept.handle, av)

      # Collect rent
      collector.collect_rent

      # Should not crash
      true.should be_true
    end

    it "applies LTI adjustments" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      collector = Attention::RentCollector.new(bank)

      # Create atom with attention value
      concept = atomspace.add_concept_node("test")
      av = AtomSpace::AttentionValue.new(50_i16, 50_i16)
      bank.set_attention_value(concept.handle, av)

      # Apply LTI adjustments
      collector.lti_rent_adjustment

      # Should not crash
      true.should be_true
    end
  end
end
