require "spec"
require "../../src/ure/ure"

describe URE do
  describe "module initialization" do
    it "initializes URE module" do
      URE.initialize
      # Should not crash
    end

    it "has correct version" do
      URE::VERSION.should eq("0.1.0")
    end
  end

  describe URE::ConjunctionRule do
    it "has correct name" do
      rule = URE::ConjunctionRule.new
      rule.name.should eq("ConjunctionRule")
    end

    it "has correct premise requirements" do
      rule = URE::ConjunctionRule.new
      premises = rule.premises
      premises.size.should eq(2)
      premises.should contain(AtomSpace::AtomType::EVALUATION_LINK)
    end

    it "has correct conclusion type" do
      rule = URE::ConjunctionRule.new
      rule.conclusion.should eq(AtomSpace::AtomType::AND_LINK)
    end

    it "applies conjunction correctly" do
      atomspace = AtomSpace::AtomSpace.new
      rule = URE::ConjunctionRule.new

      # Create two evaluation links
      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv2 = AtomSpace::SimpleTruthValue.new(0.7, 0.8)

      likes = atomspace.add_predicate_node("likes")
      john = atomspace.add_concept_node("John")
      mary = atomspace.add_concept_node("Mary")

      eval1 = atomspace.add_evaluation_link(likes, atomspace.add_list_link([john, mary]), tv1)
      eval2 = atomspace.add_evaluation_link(likes, atomspace.add_list_link([mary, john]), tv2)

      result = rule.apply([eval1, eval2], atomspace)

      result.should_not be_nil
      result.not_nil!.type.should eq(AtomSpace::AtomType::AND_LINK)

      # Truth value should be minimum of both
      tv = result.not_nil!.truth_value
      tv.strength.should eq(0.7)                # min(0.8, 0.7)
      tv.confidence.should be_close(0.72, 0.01) # min(0.9, 0.8) * 0.9
    end

    it "calculates fitness correctly" do
      atomspace = AtomSpace::AtomSpace.new
      rule = URE::ConjunctionRule.new

      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      tv2 = AtomSpace::SimpleTruthValue.new(0.7, 0.6)

      likes = atomspace.add_predicate_node("likes")
      john = atomspace.add_concept_node("John")
      mary = atomspace.add_concept_node("Mary")

      eval1 = atomspace.add_evaluation_link(likes, atomspace.add_list_link([john, mary]), tv1)
      eval2 = atomspace.add_evaluation_link(likes, atomspace.add_list_link([mary, john]), tv2)

      fitness = rule.fitness([eval1, eval2])

      # Should be average confidence: (0.9 + 0.6) / 2 = 0.75
      fitness.should be_close(0.75, 0.01)
    end
  end

  describe URE::ModusPonensRule do
    it "has correct name" do
      rule = URE::ModusPonensRule.new
      rule.name.should eq("ModusPonensRule")
    end

    it "has correct premise requirements" do
      rule = URE::ModusPonensRule.new
      premises = rule.premises
      premises.size.should eq(2)
      premises.should contain(AtomSpace::AtomType::IMPLICATION_LINK)
      premises.should contain(AtomSpace::AtomType::EVALUATION_LINK)
    end

    it "has correct conclusion type" do
      rule = URE::ModusPonensRule.new
      rule.conclusion.should eq(AtomSpace::AtomType::EVALUATION_LINK)
    end
  end

  describe URE::ForwardChainer do
    it "initializes correctly" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::ForwardChainer.new(atomspace, 50)
      chainer.should_not be_nil
    end

    it "can add rules" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::ForwardChainer.new(atomspace, 50)
      rule = URE::ConjunctionRule.new
      chainer.add_rule(rule)
      # Should not crash
    end

    it "can add default rules" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::ForwardChainer.new(atomspace, 50)
      chainer.add_default_rules
      # Should not crash
    end
  end

  describe URE::BackwardChainer do
    it "initializes correctly" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::BackwardChainer.new(atomspace, 5)
      chainer.should_not be_nil
    end

    it "can add rules" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::BackwardChainer.new(atomspace, 5)
      rule = URE::ConjunctionRule.new
      chainer.add_rule(rule)
      # Should not crash
    end

    it "can add default rules" do
      atomspace = AtomSpace::AtomSpace.new
      chainer = URE::BackwardChainer.new(atomspace, 5)
      chainer.add_default_rules
      # Should not crash
    end
  end

  describe URE::UREEngine do
    it "initializes with forward and backward chainers" do
      atomspace = AtomSpace::AtomSpace.new
      engine = URE::UREEngine.new(atomspace)
      engine.forward_chainer.should be_a(URE::ForwardChainer)
      engine.backward_chainer.should be_a(URE::BackwardChainer)
    end

    it "can add rules to both chainers" do
      atomspace = AtomSpace::AtomSpace.new
      engine = URE::UREEngine.new(atomspace)
      rule = URE::ConjunctionRule.new
      engine.add_rule(rule)
      # Should not crash
    end
  end

  describe "URE convenience methods" do
    it "creates URE engine" do
      atomspace = AtomSpace::AtomSpace.new
      engine = URE.create_engine(atomspace)

      engine.should be_a(URE::UREEngine)
    end
  end
end
