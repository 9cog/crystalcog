require "spec"
require "../../src/nlp/nlp_main"

describe "NLP Main" do
  before_each do
    CogUtil.initialize
    AtomSpace.initialize
    NLP.initialize
  end

  describe "initialization" do
    it "initializes NLP system" do
      NLP.initialize
      # Should not crash
    end

    it "has correct version" do
      NLP::VERSION.should eq("0.1.0")
    end
  end

  describe "NLP functionality" do
    it "provides text processing" do
      atomspace = AtomSpace::AtomSpace.new
      text = "Test sentence"
      atoms = NLP.process_text(text, atomspace)
      atoms.should be_a(Array(AtomSpace::Atom))
      atoms.size.should be > 0
    end

    it "provides tokenization" do
      text = "This is a test"
      tokens = NLP::Tokenizer.tokenize(text)
      tokens.should be_a(Array(String))
      tokens.size.should eq(4)
    end

    it "creates linguistic knowledge base" do
      atomspace = AtomSpace::AtomSpace.new
      NLP.create_linguistic_kb(atomspace)
      atomspace.size.should be > 0
    end
  end

  describe "system integration" do
    it "integrates with AtomSpace" do
      atomspace = AtomSpace::AtomSpace.new
      text = "Natural language processing"
      atoms = NLP.process_text(text, atomspace)
      atoms.size.should be > 0
      atomspace.size.should be > 0
    end

    it "provides linguistic statistics" do
      atomspace = AtomSpace::AtomSpace.new
      text = "The quick brown fox"
      NLP.process_text(text, atomspace)
      stats = NLP.get_linguistic_stats(atomspace)
      stats.should be_a(Hash(String, Int32))
      stats["word_atoms"].should be >= 4
    end
  end
end
