require "spec"
require "../../src/atomspace/atom"

describe AtomSpace::Atom do
  describe "AtomType" do
    it "identifies node and link types correctly" do
      AtomSpace::AtomType::CONCEPT_NODE.node?.should be_true
      AtomSpace::AtomType::CONCEPT_NODE.link?.should be_false

      AtomSpace::AtomType::INHERITANCE_LINK.link?.should be_true
      AtomSpace::AtomType::INHERITANCE_LINK.node?.should be_false
    end
  end

  describe "Node" do
    it "creates valid nodes" do
      node = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")

      node.type.should eq(AtomSpace::AtomType::CONCEPT_NODE)
      node.name.should eq("dog")
      node.outgoing.should be_empty
      node.arity.should eq(0)
      node.node?.should be_true
      node.link?.should be_false
    end

    it "rejects non-node types" do
      expect_raises(ArgumentError) do
        AtomSpace::Node.new(AtomSpace::AtomType::INHERITANCE_LINK, "invalid")
      end
    end

    it "has unique handles" do
      node1 = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      node2 = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "cat")

      node1.handle.should_not eq(node2.handle)
    end

    it "checks equality correctly" do
      node1 = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      node2 = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      node3 = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "cat")

      # Same type and name should be equal (ignoring handle)
      node1.content_equals?(node2).should be_true
      node1.content_equals?(node3).should be_false
    end

    it "converts to string correctly" do
      node = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      node.to_s.should eq("(CONCEPTNODE \"dog\")")
    end

    it "clones correctly" do
      original = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      cloned = original.clone

      cloned.should be_a(AtomSpace::Node)
      cloned.type.should eq(original.type)
      cloned.as(AtomSpace::Node).name.should eq(original.name)
      cloned.handle.should_not eq(original.handle) # Different handle
    end
  end

  describe "Link" do
    it "creates valid links" do
      dog = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      animal = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "animal")

      # Cast to Array(Atom) to satisfy the type system
      outgoing = [dog, animal].map(&.as(AtomSpace::Atom)).map(&.as(AtomSpace::Atom))
      link = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, outgoing)

      link.type.should eq(AtomSpace::AtomType::INHERITANCE_LINK)
      link.outgoing.size.should eq(2)
      link.outgoing[0].should eq(dog)
      link.outgoing[1].should eq(animal)
      link.arity.should eq(2)
      link.node?.should be_false
      link.link?.should be_true
    end

    it "rejects non-link types" do
      dog = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")

      expect_raises(ArgumentError) do
        AtomSpace::Link.new(AtomSpace::AtomType::CONCEPT_NODE, [dog].map(&.as(AtomSpace::Atom)))
      end
    end

    it "provides array-like access" do
      dog = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      animal = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "animal")

      outgoing = [dog, animal].map(&.as(AtomSpace::Atom)).map(&.as(AtomSpace::Atom))
      link = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, outgoing)

      link[0].should eq(dog)
      link[1].should eq(animal)
      link.first.should eq(dog)
      link.last.should eq(animal)
    end

    it "checks equality correctly" do
      dog = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      animal = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "animal")
      cat = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "cat")

      link1 = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, [dog, animal].map(&.as(AtomSpace::Atom)))
      link2 = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, [dog, animal].map(&.as(AtomSpace::Atom)))
      link3 = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, [cat, animal].map(&.as(AtomSpace::Atom)))

      link1.content_equals?(link2).should be_true
      link1.content_equals?(link3).should be_false
    end

    it "converts to string correctly" do
      dog = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "dog")
      animal = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "animal")

      link = AtomSpace::Link.new(AtomSpace::AtomType::INHERITANCE_LINK, [dog, animal].map(&.as(AtomSpace::Atom)))

      expected = "(INHERITANCELINK (CONCEPTNODE \"dog\") (CONCEPTNODE \"animal\"))"
      link.to_s.should eq(expected)
    end
  end

  describe "Specific node types" do
    it "creates ConceptNode correctly" do
      node = AtomSpace::ConceptNode.new("dog")
      node.type.should eq(AtomSpace::AtomType::CONCEPT_NODE)
      node.name.should eq("dog")
    end

    it "creates PredicateNode correctly" do
      node = AtomSpace::PredicateNode.new("likes")
      node.type.should eq(AtomSpace::AtomType::PREDICATE_NODE)
      node.name.should eq("likes")
    end

    it "creates VariableNode correctly" do
      node = AtomSpace::VariableNode.new("$X")
      node.type.should eq(AtomSpace::AtomType::VARIABLE_NODE)
      node.name.should eq("$X")
    end

    it "creates NumberNode correctly" do
      node = AtomSpace::NumberNode.new(42.5)
      node.type.should eq(AtomSpace::AtomType::NUMBER_NODE)
      node.name.should eq("42.5")
      node.value.should eq(42.5)

      int_node = AtomSpace::NumberNode.new(42)
      int_node.value.should eq(42.0)
    end
  end

  describe "Specific link types" do
    it "creates InheritanceLink correctly" do
      dog = AtomSpace::ConceptNode.new("dog")
      animal = AtomSpace::ConceptNode.new("animal")

      link = AtomSpace::InheritanceLink.new(dog, animal)

      link.type.should eq(AtomSpace::AtomType::INHERITANCE_LINK)
      link.child.should eq(dog)
      link.parent.should eq(animal)
    end

    it "creates EvaluationLink correctly" do
      predicate = AtomSpace::PredicateNode.new("likes")
      john = AtomSpace::ConceptNode.new("John")
      mary = AtomSpace::ConceptNode.new("Mary")
      args = AtomSpace::ListLink.new([john, mary].map(&.as(AtomSpace::Atom)))

      link = AtomSpace::EvaluationLink.new(predicate, args)

      link.type.should eq(AtomSpace::AtomType::EVALUATION_LINK)
      link.predicate.should eq(predicate)
      link.arguments.should eq(args)
    end

    it "creates ListLink correctly" do
      atoms = [
        AtomSpace::ConceptNode.new("John"),
        AtomSpace::ConceptNode.new("Mary"),
      ].map(&.as(AtomSpace::Atom))

      link = AtomSpace::ListLink.new(atoms)

      link.type.should eq(AtomSpace::AtomType::LIST_LINK)
      link.outgoing.should eq(atoms)
    end

    it "creates logical links correctly" do
      atom1 = AtomSpace::ConceptNode.new("A")
      atom2 = AtomSpace::ConceptNode.new("B")

      and_link = AtomSpace::AndLink.new([atom1, atom2].map(&.as(AtomSpace::Atom)))
      and_link.type.should eq(AtomSpace::AtomType::AND_LINK)

      or_link = AtomSpace::OrLink.new([atom1, atom2].map(&.as(AtomSpace::Atom)))
      or_link.type.should eq(AtomSpace::AtomType::OR_LINK)

      not_link = AtomSpace::NotLink.new(atom1)
      not_link.type.should eq(AtomSpace::AtomType::NOT_LINK)
      not_link.operand.should eq(atom1)
    end
  end

  describe "AttentionValue" do
    it "creates valid attention values" do
      av = AtomSpace::AttentionValue.new(100, 50, true)

      av.sti.should eq(100)
      av.lti.should eq(50)
      av.vlti.should be_true
    end

    it "has default values" do
      av = AtomSpace::AttentionValue.new

      av.sti.should eq(0)
      av.lti.should eq(0)
      av.vlti.should be_false
    end

    it "converts to string correctly" do
      av = AtomSpace::AttentionValue.new(100, 50, true)
      av.to_s.should eq("[100, 50, VLTI]")

      av_no_vlti = AtomSpace::AttentionValue.new(100, 50, false)
      av_no_vlti.to_s.should eq("[100, 50]")
    end

    it "checks equality correctly" do
      av1 = AtomSpace::AttentionValue.new(100, 50, true)
      av2 = AtomSpace::AttentionValue.new(100, 50, true)
      av3 = AtomSpace::AttentionValue.new(100, 50, false)

      av1.should eq(av2)
      av1.should_not eq(av3)
    end
  end

  describe "Truth values on atoms" do
    it "stores and retrieves truth values correctly" do
      tv = AtomSpace::SimpleTruthValue.new(0.8, 0.9)
      node = AtomSpace::ConceptNode.new("dog", tv)

      node.truth_value.should eq(tv)
      node.truth_value.strength.should eq(0.8)
      node.truth_value.confidence.should eq(0.9)
    end

    it "uses default truth value when none specified" do
      node = AtomSpace::ConceptNode.new("dog")
      node.truth_value.should eq(AtomSpace::TruthValue::DEFAULT_TV)
    end
  end

  describe "Type checking predicates" do
    it "identifies atom types correctly" do
      concept = AtomSpace::ConceptNode.new("dog")
      predicate = AtomSpace::PredicateNode.new("likes")
      variable = AtomSpace::VariableNode.new("$X")
      inheritance = AtomSpace::InheritanceLink.new(concept, concept)
      evaluation = AtomSpace::EvaluationLink.new(predicate, AtomSpace::ListLink.new([concept].map(&.as(AtomSpace::Atom))))
      list = AtomSpace::ListLink.new([concept].map(&.as(AtomSpace::Atom)))

      concept.concept_node?.should be_true
      concept.predicate_node?.should be_false

      predicate.predicate_node?.should be_true
      predicate.concept_node?.should be_false

      variable.variable_node?.should be_true

      inheritance.inheritance_link?.should be_true
      inheritance.evaluation_link?.should be_false

      evaluation.evaluation_link?.should be_true
      evaluation.inheritance_link?.should be_false

      list.list_link?.should be_true
    end
  end
end
