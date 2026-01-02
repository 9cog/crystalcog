require "spec"
require "../../src/atomspace/atomspace"

describe AtomSpace::AtomSpace do
  describe "basic operations" do
    it "creates empty atomspace" do
      atomspace = AtomSpace::AtomSpace.new

      atomspace.size.should eq(0)
      atomspace.node_count.should eq(0)
      atomspace.link_count.should eq(0)
    end

    it "adds and retrieves atoms" do
      atomspace = AtomSpace::AtomSpace.new

      dog = AtomSpace::ConceptNode.new("dog")
      added_dog = atomspace.add_atom(dog)

      atomspace.size.should eq(1)
      atomspace.node_count.should eq(1)
      atomspace.link_count.should eq(0)

      retrieved = atomspace.get_atom(added_dog.handle)
      retrieved.should eq(added_dog)
    end

    it "prevents duplicate atoms" do
      atomspace = AtomSpace::AtomSpace.new

      dog1 = AtomSpace::ConceptNode.new("dog")
      dog2 = AtomSpace::ConceptNode.new("dog")

      added1 = atomspace.add_atom(dog1)
      added2 = atomspace.add_atom(dog2)

      # Should return the same atom
      added1.should eq(added2)
      atomspace.size.should eq(1)
    end

    it "merges truth values for duplicate atoms" do
      atomspace = AtomSpace::AtomSpace.new

      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.6)
      tv2 = AtomSpace::SimpleTruthValue.new(0.7, 0.4)

      dog1 = AtomSpace::ConceptNode.new("dog", tv1)
      dog2 = AtomSpace::ConceptNode.new("dog", tv2)

      added1 = atomspace.add_atom(dog1)
      added2 = atomspace.add_atom(dog2)

      # Truth values should be merged
      merged_tv = added2.truth_value
      merged_tv.strength.should be_close(0.76, 0.01) # Weighted average
      merged_tv.confidence.should eq(1.0)            # Sum capped at 1.0
    end
  end

  describe "convenience creation methods" do
    it "creates nodes with convenience methods" do
      atomspace = AtomSpace::AtomSpace.new

      concept = atomspace.add_concept_node("dog")
      predicate = atomspace.add_predicate_node("likes")

      concept.type.should eq(AtomSpace::AtomType::CONCEPT_NODE)
      concept.as(AtomSpace::Node).name.should eq("dog")

      predicate.type.should eq(AtomSpace::AtomType::PREDICATE_NODE)
      predicate.as(AtomSpace::Node).name.should eq("likes")

      atomspace.size.should eq(2)
      atomspace.node_count.should eq(2)
    end

    it "creates links with convenience methods" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")

      inheritance = atomspace.add_inheritance_link(dog, animal)

      inheritance.type.should eq(AtomSpace::AtomType::INHERITANCE_LINK)
      inheritance.as(AtomSpace::Link).outgoing.should eq([dog, animal])

      atomspace.size.should eq(3) # 2 nodes + 1 link
      atomspace.link_count.should eq(1)
    end

    it "creates evaluation links" do
      atomspace = AtomSpace::AtomSpace.new

      likes = atomspace.add_predicate_node("likes")
      john = atomspace.add_concept_node("John")
      mary = atomspace.add_concept_node("Mary")
      args = atomspace.add_list_link([john, mary])

      evaluation = atomspace.add_evaluation_link(likes, args)

      evaluation.type.should eq(AtomSpace::AtomType::EVALUATION_LINK)
      evaluation.as(AtomSpace::EvaluationLink).predicate.should eq(likes)
      evaluation.as(AtomSpace::EvaluationLink).arguments.should eq(args)
    end
  end

  describe "lookup operations" do
    it "finds atoms by type" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      cat = atomspace.add_concept_node("cat")
      likes = atomspace.add_predicate_node("likes")

      concepts = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
      predicates = atomspace.get_atoms_by_type(AtomSpace::AtomType::PREDICATE_NODE)

      concepts.size.should eq(2)
      concepts.should contain(dog)
      concepts.should contain(cat)

      predicates.size.should eq(1)
      predicates.should contain(likes)
    end

    it "finds nodes by name" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      dog_predicate = atomspace.add_predicate_node("dog") # Same name, different type

      # Find all nodes with name "dog"
      all_dogs = atomspace.get_nodes_by_name("dog")
      all_dogs.size.should eq(2)
      all_dogs.should contain(dog)
      all_dogs.should contain(dog_predicate)

      # Find only concept nodes with name "dog"
      concept_dogs = atomspace.get_nodes_by_name("dog", AtomSpace::AtomType::CONCEPT_NODE)
      concept_dogs.size.should eq(1)
      concept_dogs.should contain(dog)
    end

    it "checks atom containment" do
      atomspace = AtomSpace::AtomSpace.new

      dog = AtomSpace::ConceptNode.new("dog")
      added_dog = atomspace.add_atom(dog)

      atomspace.contains?(added_dog).should be_true
      atomspace.contains?(added_dog.handle).should be_true

      cat = AtomSpace::ConceptNode.new("cat")
      atomspace.contains?(cat).should be_false
    end
  end

  describe "removal operations" do
    it "removes atoms without incoming links" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      atomspace.size.should eq(1)

      success = atomspace.remove_atom(dog)
      success.should be_true
      atomspace.size.should eq(0)
    end

    it "prevents removal of atoms with incoming links" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      inheritance = atomspace.add_inheritance_link(dog, animal)

      # Should not be able to remove dog because it has incoming link
      success = atomspace.remove_atom(dog)
      success.should be_false
      atomspace.size.should eq(3)
    end

    it "clears all atoms" do
      atomspace = AtomSpace::AtomSpace.new

      atomspace.add_concept_node("dog")
      atomspace.add_concept_node("cat")
      atomspace.add_predicate_node("likes")

      atomspace.size.should eq(3)

      atomspace.clear
      atomspace.size.should eq(0)
      atomspace.node_count.should eq(0)
      atomspace.link_count.should eq(0)
    end
  end

  describe "incoming links" do
    it "finds incoming links correctly" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      mammal = atomspace.add_concept_node("mammal")

      inheritance1 = atomspace.add_inheritance_link(dog, animal)
      inheritance2 = atomspace.add_inheritance_link(dog, mammal)

      incoming = atomspace.get_incoming(dog)
      incoming.size.should eq(2)
      incoming.should contain(inheritance1)
      incoming.should contain(inheritance2)

      # Animal should have one incoming link (as parent in inheritance)
      animal_incoming = atomspace.get_incoming(animal)
      animal_incoming.size.should eq(1)
      animal_incoming.should contain(inheritance1)
    end
  end

  describe "pattern matching" do
    it "finds atoms satisfying patterns" do
      atomspace = AtomSpace::AtomSpace.new

      dog = atomspace.add_concept_node("dog")
      cat = atomspace.add_concept_node("cat")
      likes = atomspace.add_predicate_node("likes")

      # Create pattern for any concept node
      pattern = AtomSpace::ConceptNode.new("*") # Wildcard

      # This is a basic implementation - real pattern matching would be more sophisticated
      matches = atomspace.find_atoms(pattern)
      matches.size.should eq(2) # dog and cat
    end
  end

  describe "event system" do
    it "notifies observers of atom addition" do
      atomspace = AtomSpace::AtomSpace.new

      events = [] of AtomSpace::AtomSpaceEvent
      atoms = [] of AtomSpace::Atom

      observer = ->(event : AtomSpace::AtomSpaceEvent, atom : AtomSpace::Atom) {
        events << event
        atoms << atom
      }

      atomspace.add_observer(observer)

      dog = atomspace.add_concept_node("dog")

      events.size.should eq(1)
      events[0].should eq(AtomSpace::AtomSpaceEvent::ATOM_ADDED)
      atoms[0].should eq(dog)
    end

    it "notifies observers of truth value changes" do
      atomspace = AtomSpace::AtomSpace.new

      events = [] of AtomSpace::AtomSpaceEvent

      observer = ->(event : AtomSpace::AtomSpaceEvent, atom : AtomSpace::Atom) {
        events << event
      }

      atomspace.add_observer(observer)

      # Add atom first
      tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.6)
      dog1 = AtomSpace::ConceptNode.new("dog", tv1)
      atomspace.add_atom(dog1)

      # Add same atom with different truth value
      tv2 = AtomSpace::SimpleTruthValue.new(0.7, 0.4)
      dog2 = AtomSpace::ConceptNode.new("dog", tv2)
      atomspace.add_atom(dog2)

      events.size.should eq(2)
      events[0].should eq(AtomSpace::AtomSpaceEvent::ATOM_ADDED)
      events[1].should eq(AtomSpace::AtomSpaceEvent::TRUTH_VALUE_CHANGED)
    end
  end

  describe "statistics" do
    it "provides accurate statistics" do
      atomspace = AtomSpace::AtomSpace.new

      # Add some atoms
      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      likes = atomspace.add_predicate_node("likes")
      inheritance = atomspace.add_inheritance_link(dog, animal)

      atomspace.size.should eq(4)
      atomspace.node_count.should eq(3)
      atomspace.link_count.should eq(1)
    end

    it "provides debug output" do
      atomspace = AtomSpace::AtomSpace.new
      atomspace.add_concept_node("dog")
      atomspace.add_concept_node("cat")

      # Should not crash
      atomspace.print_statistics
      atomspace.to_s.should contain("AtomSpace")
    end
  end

  describe "global atomspace management" do
    it "provides default atomspace" do
      default_as = AtomSpace::AtomSpaceManager.default_atomspace
      default_as.should be_a(AtomSpace::AtomSpace)

      # Should return same instance
      same_as = AtomSpace::AtomSpaceManager.default_atomspace
      same_as.should eq(default_as)
    end

    it "allows setting custom default atomspace" do
      custom_as = AtomSpace::AtomSpace.new
      AtomSpace::AtomSpaceManager.set_default_atomspace(custom_as)

      retrieved = AtomSpace::AtomSpaceManager.default_atomspace
      retrieved.should eq(custom_as)
    end

    it "provides convenience methods for default atomspace" do
      AtomSpace::AtomSpaceManager.clear

      dog = AtomSpace::ConceptNode.new("dog")
      added = AtomSpace::AtomSpaceManager.add_atom(dog)

      AtomSpace::AtomSpaceManager.size.should eq(1)

      node = AtomSpace::AtomSpaceManager.add_node(AtomSpace::AtomType::CONCEPT_NODE, "cat")
      AtomSpace::AtomSpaceManager.size.should eq(2)
    end
  end
end
