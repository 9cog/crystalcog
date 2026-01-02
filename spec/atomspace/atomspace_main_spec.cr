require "spec"
require "../../src/atomspace/atomspace_main"

describe "AtomSpace Main" do
  describe "initialization" do
    it "initializes AtomSpace system" do
      AtomSpace.initialize
      # Should not crash
    end

    it "has correct version" do
      AtomSpace::VERSION.should eq("0.1.0")
    end

    it "creates default atomspace" do
      atomspace = AtomSpace::AtomSpace.new
      atomspace.should be_a(AtomSpace::AtomSpace)
    end
  end

  describe "factory methods" do
    it "provides factory for atom creation" do
      atomspace = AtomSpace::AtomSpace.new

      # Should be able to create basic atoms
      concept = atomspace.add_concept_node("test")
      concept.should be_a(AtomSpace::ConceptNode)
      concept.name.should eq("test")
    end

    it "provides factory for link creation" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")

      inheritance = atomspace.add_inheritance_link(dog, animal)
      inheritance.should be_a(AtomSpace::InheritanceLink)
    end
  end

  describe "system integration" do
    it "integrates with CogUtil" do
      CogUtil.initialize
      AtomSpace.initialize

      # Should work together
      atomspace = AtomSpace::AtomSpace.new
      atomspace.should_not be_nil
    end
  end
end
