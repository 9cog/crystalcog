require "spec"
require "../../src/attention/attention_bank"

describe Attention::AttentionBank do
  describe "initialization" do
    it "creates attention bank" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)

      bank.should_not be_nil
    end

    it "has default STI and LTI funds" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)

      bank.sti_funds.should eq(10000)
      bank.lti_funds.should eq(10000)
    end

    it "allows custom funds" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace, 5000, 3000)

      bank.sti_funds.should eq(5000)
      bank.lti_funds.should eq(3000)
    end
  end

  describe "attention values" do
    it "sets attention values" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      concept = atomspace.add_concept_node("test")

      av = AtomSpace::AttentionValue.new(100_i16, 50_i16)
      bank.set_attention_value(concept.handle, av)
      retrieved_av = bank.get_attention_value(concept.handle)
      retrieved_av.should_not be_nil
    end

    it "stimulates atoms" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      concept = atomspace.add_concept_node("test")

      # Should be able to stimulate an atom
      bank.stimulate(concept.handle, 50_i16)
      # Should not crash
    end
  end
end
