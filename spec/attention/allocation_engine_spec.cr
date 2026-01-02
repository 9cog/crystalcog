require "spec"
require "../../src/attention/allocation_engine"

describe Attention::AllocationEngine do
  describe "initialization" do
    it "creates allocation engine" do
      atomspace = AtomSpace::AtomSpace.new
      engine = Attention::AllocationEngine.new(atomspace)

      engine.should_not be_nil
    end

    it "has default parameters" do
      atomspace = AtomSpace::AtomSpace.new
      engine = Attention::AllocationEngine.new(atomspace)

      engine.bank.should_not be_nil
      engine.diffusion.should_not be_nil
      engine.rent_collector.should_not be_nil
    end
  end

  describe "allocation functionality" do
    it "performs attention allocation" do
      atomspace = AtomSpace::AtomSpace.new
      engine = Attention::AllocationEngine.new(atomspace)

      # Add some atoms
      concept = atomspace.add_concept_node("test")

      # Should be able to allocate attention
      engine.allocate_attention(1)
      # Should not crash
    end

    it "respects cycle limits" do
      atomspace = AtomSpace::AtomSpace.new
      engine = Attention::AllocationEngine.new(atomspace)

      # Should complete allocation cycles
      engine.allocate_attention(3)
      # Should not crash or hang
    end
  end
end
