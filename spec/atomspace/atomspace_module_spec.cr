require "spec"
require "../../src/atomspace/atomspace_module"

describe "AtomSpace Module" do
  describe "module components" do
    it "defines AtomSpace module" do
      AtomSpace.should be_truthy
    end

    it "provides atom types" do
      AtomSpace::AtomType.should be_truthy
      AtomSpace::AtomType::CONCEPT_NODE.should be_truthy
      AtomSpace::AtomType::INHERITANCE_LINK.should be_truthy
    end

    it "provides base atom classes" do
      AtomSpace::Atom.should be_truthy
      AtomSpace::Node.should be_truthy
      AtomSpace::Link.should be_truthy
    end

    it "provides truth value system" do
      AtomSpace::TruthValue.should be_truthy
      AtomSpace::SimpleTruthValue.should be_truthy
    end
  end

  describe "type system" do
    it "defines node types" do
      AtomSpace::ConceptNode.should be_truthy
      AtomSpace::PredicateNode.should be_truthy
      AtomSpace::VariableNode.should be_truthy
    end

    it "defines link types" do
      AtomSpace::InheritanceLink.should be_truthy
      AtomSpace::EvaluationLink.should be_truthy
      AtomSpace::ListLink.should be_truthy
    end
  end

  describe "module integration" do
    it "works with main AtomSpace" do
      # Module should integrate with main system
      AtomSpace.initialize

      # Should be able to create atomspace
      atomspace = AtomSpace::AtomSpace.new
      atomspace.should_not be_nil
    end
  end
end
