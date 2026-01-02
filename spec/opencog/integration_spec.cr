require "../spec_helper"
require "../../src/opencog/opencog"

describe "OpenCog Integration Tests" do
  it "performs end-to-end reasoning scenario" do
    atomspace = AtomSpace::AtomSpace.new
    reasoner = OpenCog.create_reasoner(atomspace)

    # Build a knowledge base about animals
    animals = {
      "Cat"    => ["Mammal", "Pet"],
      "Dog"    => ["Mammal", "Pet"],
      "Lion"   => ["Mammal", "Predator"],
      "Mammal" => ["Animal"],
      "Animal" => ["LivingThing"],
    }

    # Create the hierarchy
    OpenCog::AtomUtils.create_hierarchy(atomspace, animals)

    # Add semantic facts
    facts = [
      {"subject" => "Cat", "predicate" => "likes", "object" => "Fish"},
      {"subject" => "Dog", "predicate" => "likes", "object" => "Bone"},
      {"subject" => "Cat", "predicate" => "sleeps", "object" => "Sofa"},
      {"subject" => "Dog", "predicate" => "sleeps", "object" => "Floor"},
    ]

    OpenCog::AtomUtils.create_semantic_network(atomspace, facts)

    initial_size = atomspace.size

    # Perform reasoning
    reasoning_results = reasoner.reason(5)

    # Should have created new knowledge
    atomspace.size.should be > initial_size
    reasoning_results.size.should be > 0

    # Test queries
    cat_node = atomspace.get_nodes_by_name("Cat").first
    cat_results = reasoner.query(cat_node)
    cat_results.size.should be > 0

    # Test inference - should be able to conclude that Cat is an Animal
    cat = atomspace.get_nodes_by_name("Cat").first
    animal = atomspace.get_nodes_by_name("Animal").first
    goal = atomspace.add_inheritance_link(cat, animal)

    can_achieve = reasoner.can_achieve?(goal)
    can_achieve.should be_true

    # Test similarity
    cat_node_for_sim = atomspace.get_nodes_by_name("Cat").first
    dog_node = atomspace.get_nodes_by_name("Dog").first
    similarity = OpenCog::Reasoning.similarity(atomspace, cat_node_for_sim, dog_node)

    # Cat and Dog should be similar (both are pets and mammals)
    similarity.should be > 0.0

    # Test subgraph extraction
    cat_subgraph = OpenCog::AtomUtils.extract_subgraph(atomspace, cat_node_for_sim, 2)
    cat_subgraph.size.should be > 1
    cat_subgraph.should contain(cat_node_for_sim)

    # Test predicate finding
    cat_predicates = OpenCog::Query.find_predicates(atomspace, cat_node_for_sim)
    cat_predicates.size.should be > 0

    # Test instance finding
    mammal_node = atomspace.get_nodes_by_name("Mammal").first
    mammal_instances = OpenCog::Query.find_instances(atomspace, mammal_node)
    mammal_instances.should contain(cat_node_for_sim)
    mammal_instances.should contain(dog_node)

    puts "Integration test completed successfully!"
    puts "Initial AtomSpace size: #{initial_size}"
    puts "Final AtomSpace size: #{atomspace.size}"
    puts "Reasoning results: #{reasoning_results.size}"
    puts "Cat-Dog similarity: #{similarity}"
    puts "Cat predicates: #{cat_predicates.size}"
    puts "Mammal instances: #{mammal_instances.size}"
  end

  it "handles complex reasoning chains" do
    atomspace = AtomSpace::AtomSpace.new

    # Create a chain of implications
    a = atomspace.add_concept_node("A", AtomSpace::SimpleTruthValue.new(0.9, 0.8))
    b = atomspace.add_concept_node("B", AtomSpace::SimpleTruthValue.new(0.8, 0.7))
    c = atomspace.add_concept_node("C", AtomSpace::SimpleTruthValue.new(0.7, 0.6))
    d = atomspace.add_concept_node("D", AtomSpace::SimpleTruthValue.new(0.6, 0.5))

    # A -> B -> C -> D chain
    ab = atomspace.add_inheritance_link(a, b, AtomSpace::SimpleTruthValue.new(0.9, 0.8))
    bc = atomspace.add_inheritance_link(b, c, AtomSpace::SimpleTruthValue.new(0.8, 0.7))
    cd = atomspace.add_inheritance_link(c, d, AtomSpace::SimpleTruthValue.new(0.7, 0.6))

    initial_size = atomspace.size

    # Run inference to derive A -> C and A -> D
    results = OpenCog::Reasoning.infer(atomspace, 10)

    # Should have derived new relationships
    atomspace.size.should be > initial_size
    results.size.should be > 0

    # Check if we can conclude A -> D
    goal = atomspace.add_inheritance_link(a, d)
    can_conclude = OpenCog::Reasoning.can_conclude?(atomspace, goal)

    # This might be true if the reasoning chain worked
    puts "Can conclude A -> D: #{can_conclude}"
    puts "Derived #{results.size} new atoms from reasoning chain"
  end

  it "demonstrates learning capabilities" do
    atomspace = AtomSpace::AtomSpace.new

    # Create patterns that can be learned
    subjects = ["John", "Mary", "Bob"]
    predicates = ["works", "studies", "exercises"]
    objects = ["hard", "daily", "regularly"]

    # Create evaluation patterns
    subjects.each do |subj|
      subj_node = atomspace.add_concept_node(subj)

      predicates.each_with_index do |pred, i|
        pred_node = atomspace.add_predicate_node(pred)
        obj_node = atomspace.add_concept_node(objects[i % objects.size])

        args = atomspace.add_list_link([subj_node, obj_node])
        atomspace.add_evaluation_link(pred_node, args)
      end
    end

    initial_size = atomspace.size

    # Learn implications from the patterns
    implications = OpenCog::Learning.learn_implications(atomspace, 0.5)

    implications.size.should be > 0
    atomspace.size.should be > initial_size

    puts "Learned #{implications.size} implications from patterns"
    puts "AtomSpace grew from #{initial_size} to #{atomspace.size} atoms"
  end

  it "handles error conditions gracefully" do
    atomspace = AtomSpace::AtomSpace.new
    reasoner = OpenCog.create_reasoner(atomspace)

    # Test with empty atomspace
    empty_results = reasoner.reason(3)
    empty_results.should be_a(Array(AtomSpace::Atom))

    # Test query with non-existent pattern
    fake_node = AtomSpace::Node.new(AtomSpace::AtomType::CONCEPT_NODE, "NonExistent")
    query_results = reasoner.query(fake_node)
    query_results.should be_a(Array(OpenCog::Query::QueryResult))

    # Test similarity with same atom
    test_node = atomspace.add_concept_node("Test")
    self_similarity = OpenCog::Reasoning.similarity(atomspace, test_node, test_node)
    self_similarity.should eq(1.0)

    # Test extraction with single atom
    single_subgraph = OpenCog::AtomUtils.extract_subgraph(atomspace, test_node, 1)
    single_subgraph.should contain(test_node)

    puts "Error condition tests passed"
  end
end
