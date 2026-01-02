require "spec"
require "../../src/nlp/nlp"

describe NLP do
  before_each do
    CogUtil.initialize
    AtomSpace.initialize
    NLP.initialize
  end

  describe "initialization" do
    it "initializes without errors" do
      # NLP.initialize should have been called in before_each
      # Test that we can access NLP constants
      NLP::VERSION.should be_a(String)
      NLP::VERSION.should eq("0.1.0")
    end
  end

  describe "text processing pipeline" do
    it "processes simple text into atoms" do
      atomspace = AtomSpace::AtomSpace.new

      text = "The cat sits"
      atoms = NLP.process_text(text, atomspace)

      # Should create word atoms, sentence structure, etc.
      atoms.size.should be > 0
      atomspace.size.should be > 0

      # Should contain word atoms
      word_atoms = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .select { |atom| atom.name.starts_with?("word:") }
      word_atoms.size.should be >= 3 # the, cat, sits
    end

    it "handles empty text gracefully" do
      atomspace = AtomSpace::AtomSpace.new

      expect_raises(NLP::TokenizationException) do
        NLP.process_text("", atomspace)
      end
    end

    it "creates sentence structures for multi-word input" do
      atomspace = AtomSpace::AtomSpace.new

      text = "Dogs are animals"
      atoms = NLP.process_text(text, atomspace)

      # Should create sentence structure atoms
      list_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::LIST_LINK)
      list_links.size.should be >= 1

      evaluation_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::EVALUATION_LINK)
      evaluation_links.size.should be >= 1
    end
  end

  describe "linguistic knowledge base" do
    it "creates basic linguistic concepts" do
      atomspace = AtomSpace::AtomSpace.new

      NLP.create_linguistic_kb(atomspace)

      # Should create basic linguistic concepts
      concepts = atomspace.get_atoms_by_type(AtomSpace::AtomType::CONCEPT_NODE)
        .map(&.name)

      concepts.should contain("word")
      concepts.should contain("sentence")
      concepts.should contain("noun")
      concepts.should contain("verb")
      concepts.should contain("adjective")

      # Should create inheritance relationships
      inheritance_links = atomspace.get_atoms_by_type(AtomSpace::AtomType::INHERITANCE_LINK)
      inheritance_links.size.should be >= 3
    end
  end

  describe "linguistic statistics" do
    it "calculates accurate statistics" do
      atomspace = AtomSpace::AtomSpace.new

      # Add some test linguistic data
      text = "The quick brown fox jumps"
      NLP.process_text(text, atomspace)

      stats = NLP.get_linguistic_stats(atomspace)

      stats["word_atoms"].should be >= 5                   # Should have word atoms for each token
      stats["total_atoms"].should be > stats["word_atoms"] # Should have additional structure atoms
    end

    it "handles empty atomspace" do
      atomspace = AtomSpace::AtomSpace.new

      stats = NLP.get_linguistic_stats(atomspace)

      stats["word_atoms"].should eq(0)
      stats["sentence_atoms"].should eq(0)
      stats["total_atoms"].should eq(0)
    end
  end

  describe "integration with existing systems" do
    it "integrates with AtomSpace correctly" do
      atomspace = AtomSpace::AtomSpace.new

      # Verify that NLP atoms can coexist with other atom types
      dog = atomspace.add_concept_node("dog")
      animal = atomspace.add_concept_node("animal")
      inheritance = atomspace.add_inheritance_link(dog, animal)

      initial_size = atomspace.size

      # Add NLP content
      text = "Dogs are pets"
      nlp_atoms = NLP.process_text(text, atomspace)

      # Should have added atoms without conflicts
      atomspace.size.should be > initial_size
      nlp_atoms.size.should be > 0

      # Original atoms should still exist
      atomspace.contains?(dog).should be_true
      atomspace.contains?(animal).should be_true
      atomspace.contains?(inheritance).should be_true
    end

    it "uses CogUtil logging correctly" do
      # This test verifies that logging calls don't crash
      # We can't easily test log output in specs, but we can ensure no exceptions
      atomspace = AtomSpace::AtomSpace.new

      expect_raises(NLP::TokenizationException) do
        NLP.process_text("", atomspace)
      end

      # Normal processing should work without exceptions
      text = "Testing logging"
      atoms = NLP.process_text(text, atomspace)
      atoms.size.should be > 0
    end
  end

  describe "error handling" do
    it "raises appropriate exceptions for invalid input" do
      atomspace = AtomSpace::AtomSpace.new

      expect_raises(NLP::TokenizationException) do
        NLP.process_text("", atomspace)
      end
    end

    it "handles unicode and special characters" do
      atomspace = AtomSpace::AtomSpace.new

      # Test with unicode characters
      text = "Café naïve résumé"
      atoms = NLP.process_text(text, atomspace)

      atoms.size.should be > 0
      atomspace.size.should be > 0
    end
  end
end
