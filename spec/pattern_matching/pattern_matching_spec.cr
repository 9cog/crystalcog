require "spec"
require "../../src/pattern_matching/pattern_matching"

describe PatternMatching do
  describe "initialization" do
    it "initializes PatternMatching module" do
      PatternMatching.initialize
      # Should not crash
    end
  end

  describe "Pattern" do
    it "creates pattern with atom" do
      atomspace = AtomSpace::AtomSpace.new
      concept = atomspace.add_concept_node("test")
      pattern = PatternMatching::Pattern.new(concept)

      pattern.should_not be_nil
    end
  end

  describe "MatchResult" do
    it "creates match result" do
      bindings = {} of AtomSpace::Atom => AtomSpace::Atom
      atoms = [] of AtomSpace::Atom
      result = PatternMatching::MatchResult.new(bindings, atoms)
      result.should_not be_nil
    end
  end

  describe "TypeConstraint" do
    it "creates type constraint" do
      atomspace = AtomSpace::AtomSpace.new
      var = AtomSpace::VariableNode.new("$X")
      constraint = PatternMatching::TypeConstraint.new(var, AtomSpace::AtomType::CONCEPT_NODE)
      constraint.should_not be_nil
    end
  end

  describe "PatternMatcher" do
    it "creates pattern matcher" do
      atomspace = AtomSpace::AtomSpace.new
      matcher = PatternMatching::PatternMatcher.new(atomspace)
      matcher.should_not be_nil
    end
  end
end
