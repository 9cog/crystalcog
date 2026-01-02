require "spec"
require "../../src/nlp/nlp"

describe NLP::LinguisticAtoms do
  before_each do
    CogUtil.initialize
    AtomSpace.initialize
    NLP.initialize
  end

  describe "word atom creation" do
    it "creates basic word atoms" do
      atomspace = AtomSpace::AtomSpace.new

      word_atom = NLP::LinguisticAtoms.create_word_atom(atomspace, "cat")

      word_atom.should be_a(AtomSpace::Atom)
      word_atom.name.should eq("word:cat")
      atomspace.contains?(word_atom).should be_true
    end

    it "creates word atoms with part-of-speech" do
      atomspace = AtomSpace::AtomSpace.new

      word_atom = NLP::LinguisticAtoms.create_word_atom(atomspace, "cat", "noun")

      word_atom.name.should eq("word:cat")

      # Should also create POS atom and relationship
      pos_atoms = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .select { |atom| atom.name.starts_with?("pos:") }
      pos_atoms.size.should be >= 1
      pos_atoms.any? { |atom| atom.name == "pos:noun" }.should be_true

      # Should create inheritance relationship
      inheritance_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::INHERITANCE_LINK)
      inheritance_links.size.should be >= 1
    end
  end

  describe "sentence structure creation" do
    it "creates sentence structure from tokens" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["the", "cat", "sits"]
      atoms = NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)

      atoms.size.should be > tokens.size # Should create additional structure atoms

      # Should create word atoms
      word_atoms = atoms.select { |atom| atom.name.starts_with?("word:") }
      word_atoms.size.should eq(3)

      # Should create list link for sentence
      list_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::LIST_LINK)
      list_links.size.should be >= 1

      # Should create sentence concept and evaluation
      sentence_concepts = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .select { |atom| atom.name == "sentence" }
      sentence_concepts.size.should be >= 1
    end

    it "creates ordered links between adjacent words" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["hello", "world"]
      atoms = NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)

      # Should create ordered links between adjacent words
      ordered_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::ORDERED_LINK)
      ordered_links.size.should be >= 1
    end

    it "handles single word input" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["hello"]
      atoms = NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)

      # Should create word atom but minimal structure for single word
      atoms.size.should be >= 1
      word_atoms = atoms.select { |atom| atom.name == "word:hello" }
      word_atoms.size.should eq(1)
    end

    it "handles empty token array" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = [] of String
      atoms = NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)

      atoms.should eq([] of AtomSpace::Atom)
    end
  end

  describe "semantic relation creation" do
    it "creates semantic relationships between words" do
      atomspace = AtomSpace::AtomSpace.new

      relation = NLP::LinguisticAtoms.create_semantic_relation(
        atomspace, "dog", "animal", "isa", 0.9
      )

      relation.should be_a(AtomSpace::Atom)

      # Should create word atoms
      word_atoms = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .select { |atom| atom.name.starts_with?("word:") }
      word_atoms.size.should be >= 2

      # Should create predicate atom
      predicate_atoms = atomspace.get_atoms_by_type(AtomSpace::AtomType::PREDICATE_NODE)
      predicate_atoms.any? { |atom| atom.name == "isa" }.should be_true

      # Should create evaluation link
      evaluation_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::EVALUATION_LINK)
      evaluation_links.size.should be >= 1
    end

    it "uses default confidence value" do
      atomspace = AtomSpace::AtomSpace.new

      relation = NLP::LinguisticAtoms.create_semantic_relation(
        atomspace, "cat", "pet", "isa"
      )

      # Should use default confidence (0.8)
      relation.should be_a(AtomSpace::Atom)
    end
  end

  describe "parse tree creation" do
    it "creates basic parse tree structure" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["the", "big", "dog", "runs"]
      structure = [[0, 1, 2], [3]] # "the big dog" and "runs"

      atoms = NLP::LinguisticAtoms.create_parse_tree(atomspace, tokens, structure)

      atoms.size.should be > tokens.size

      # Should create word atoms
      word_atoms = atoms.select { |atom| atom.name.starts_with?("word:") }
      word_atoms.size.should eq(4)

      # Should create phrase structures
      phrase_concepts = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .select { |atom| atom.name == "phrase" }
      phrase_concepts.size.should be >= 1
    end

    it "handles simple structure" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["hello"]
      structure = [[0]]

      atoms = NLP::LinguisticAtoms.create_parse_tree(atomspace, tokens, structure)

      # Should create word atom and phrase structure
      atoms.size.should be >= 1
    end
  end

  describe "lexical relations" do
    it "creates predefined lexical relationships" do
      atomspace = AtomSpace::AtomSpace.new

      atoms = NLP::LinguisticAtoms.create_lexical_relations(atomspace)

      atoms.size.should be > 0

      # Should create semantic relations
      evaluation_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::EVALUATION_LINK)
      evaluation_links.size.should be >= 8 # Should have multiple relations

      # Should create predicate atoms for different relation types
      predicate_atoms = atomspace.get_atoms_by_type(AtomSpace::AtomType::PREDICATE_NODE)
      relation_types = predicate_atoms.map(&.name)
      relation_types.should contain("synonym")
      relation_types.should contain("antonym")
      relation_types.should contain("hypernym")
    end
  end

  describe "atom retrieval" do
    it "extracts word atoms correctly" do
      atomspace = AtomSpace::AtomSpace.new

      # Add some word atoms and other atoms
      NLP::LinguisticAtoms.create_word_atom(atomspace, "cat")
      NLP::LinguisticAtoms.create_word_atom(atomspace, "dog")
      atomspace.add_node(AtomSpace::AtomType::CONCEPT_NODE, "not-a-word")

      word_atoms = NLP::LinguisticAtoms.get_word_atoms(atomspace)

      word_atoms.size.should eq(2)
      word_atoms.all? { |atom| atom.name.starts_with?("word:") }.should be_true
    end

    it "extracts sentence atoms correctly" do
      atomspace = AtomSpace::AtomSpace.new

      tokens = ["hello", "world"]
      NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)

      sentence_atoms = NLP::LinguisticAtoms.get_sentence_atoms(atomspace)

      sentence_atoms.size.should be >= 1
    end

    it "extracts semantic relations by type" do
      atomspace = AtomSpace::AtomSpace.new

      NLP::LinguisticAtoms.create_semantic_relation(atomspace, "dog", "animal", "isa")
      NLP::LinguisticAtoms.create_semantic_relation(atomspace, "cat", "pet", "isa")
      NLP::LinguisticAtoms.create_semantic_relation(atomspace, "happy", "sad", "antonym")

      isa_relations = NLP::LinguisticAtoms.get_semantic_relations(atomspace, "isa")
      antonym_relations = NLP::LinguisticAtoms.get_semantic_relations(atomspace, "antonym")

      isa_relations.size.should eq(2)
      antonym_relations.size.should eq(1)
    end

    it "handles empty atomspace for retrieval" do
      atomspace = AtomSpace::AtomSpace.new

      word_atoms = NLP::LinguisticAtoms.get_word_atoms(atomspace)
      sentence_atoms = NLP::LinguisticAtoms.get_sentence_atoms(atomspace)
      isa_relations = NLP::LinguisticAtoms.get_semantic_relations(atomspace, "isa")

      word_atoms.should eq([] of AtomSpace::Atom)
      sentence_atoms.should eq([] of AtomSpace::Atom)
      isa_relations.should eq([] of AtomSpace::Atom)
    end
  end

  describe "linguistic complexity metrics" do
    it "calculates complexity metrics" do
      atomspace = AtomSpace::AtomSpace.new

      # Add some linguistic content
      tokens = ["the", "cat", "sits"]
      NLP::LinguisticAtoms.create_sentence_structure(atomspace, tokens)
      NLP::LinguisticAtoms.create_semantic_relation(atomspace, "cat", "animal", "isa")

      complexity = NLP::LinguisticAtoms.get_linguistic_complexity(atomspace)

      complexity["word_count"].should be >= 3
      complexity["sentence_count"].should be >= 1
      complexity["evaluation_links"].should be > 0
      complexity["list_links"].should be > 0
      complexity["total_linguistic_atoms"].should be > 0
    end

    it "handles empty atomspace for complexity" do
      atomspace = AtomSpace::AtomSpace.new

      complexity = NLP::LinguisticAtoms.get_linguistic_complexity(atomspace)

      complexity["word_count"].should eq(0)
      complexity["sentence_count"].should eq(0)
      complexity["total_linguistic_atoms"].should eq(0)
    end
  end

  describe "integration" do
    it "works with existing atomspace content" do
      atomspace = AtomSpace::AtomSpace.new

      # Add some non-linguistic content
      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      inheritance = atomspace.add_inheritance_link(dog, animal)

      initial_size = atomspace.size

      # Add linguistic content
      word_atom = NLP::LinguisticAtoms.create_word_atom(atomspace, "dog")

      # Should coexist without conflicts
      atomspace.size.should be > initial_size
      atomspace.contains?(dog).should be_true
      atomspace.contains?(animal).should be_true
      atomspace.contains?(inheritance).should be_true
      atomspace.contains?(word_atom).should be_true
    end
  end
end
