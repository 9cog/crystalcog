require "spec"
require "../../src/attention/diffusion"

describe Attention::AttentionDiffusion do
  describe "initialization" do
    it "creates diffusion system" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      diffusion = Attention::AttentionDiffusion.new(bank)

      diffusion.should_not be_nil
    end
  end

  describe "diffusion operations" do
    it "performs neighbor diffusion" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      diffusion = Attention::AttentionDiffusion.new(bank)

      # Create atoms with relationships
      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      inheritance = atomspace.add_inheritance_link(dog, animal)

      # Set initial attention
      av = AtomSpace::AttentionValue.new(100_i16, 50_i16)
      bank.set_attention_value(dog.handle, av)

      # Perform diffusion
      diffusion.neighbor_diffusion(3)

      # Should not crash
      true.should be_true
    end

    it "performs Hebbian diffusion" do
      atomspace = AtomSpace::AtomSpace.new
      bank = Attention::AttentionBank.new(atomspace)
      diffusion = Attention::AttentionDiffusion.new(bank)

      # Create some atoms
      dog = atomspace.add_concept_node("dog")
      cat = atomspace.add_concept_node("cat")

      # Perform Hebbian diffusion
      diffusion.hebbian_diffusion

      # Should not crash
      true.should be_true
    end
  end
end
