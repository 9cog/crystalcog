require "spec"
require "../../src/nlp/nlp"

describe NLP::Tokenizer do
  describe "basic tokenization" do
    it "tokenizes simple sentences" do
      text = "The quick brown fox"
      tokens = NLP::Tokenizer.tokenize(text)

      tokens.should eq(["the", "quick", "brown", "fox"])
      tokens.size.should eq(4)
    end

    it "handles punctuation" do
      text = "Hello, world!"
      tokens = NLP::Tokenizer.tokenize(text)

      tokens.should contain("hello")
      tokens.should contain("world")
      # Punctuation should be cleaned but tokens preserved
    end

    it "normalizes to lowercase" do
      text = "Hello World"
      tokens = NLP::Tokenizer.tokenize(text)

      tokens.should eq(["hello", "world"])
    end

    it "handles multiple whitespace" do
      text = "word1   word2\t\tword3\n\nword4"
      tokens = NLP::Tokenizer.tokenize(text)

      tokens.should eq(["word1", "word2", "word3", "word4"])
    end

    it "raises exception for empty text" do
      expect_raises(NLP::TokenizationException) do
        NLP::Tokenizer.tokenize("")
      end
    end
  end

  describe "sentence tokenization" do
    it "splits text into sentences" do
      text = "First sentence. Second sentence! Third sentence?"
      sentences = NLP::Tokenizer.split_sentences(text)

      sentences.size.should eq(3)
      sentences[0].should contain("First sentence")
      sentences[1].should contain("Second sentence")
      sentences[2].should contain("Third sentence")
    end

    it "tokenizes each sentence separately" do
      text = "Hello world. Goodbye world."
      sentence_tokens = NLP::Tokenizer.tokenize_sentences(text)

      sentence_tokens.size.should eq(2)
      sentence_tokens[0].should eq(["hello", "world"])
      sentence_tokens[1].should eq(["goodbye", "world"])
    end
  end

  describe "token classification" do
    it "identifies words correctly" do
      NLP::Tokenizer.is_word?("hello").should be_true
      NLP::Tokenizer.is_word?("Hello").should be_true
      NLP::Tokenizer.is_word?("123").should be_false
      NLP::Tokenizer.is_word?("hello123").should be_false
    end

    it "identifies numbers correctly" do
      NLP::Tokenizer.is_number?("123").should be_true
      NLP::Tokenizer.is_number?("12.34").should be_true
      NLP::Tokenizer.is_number?("hello").should be_false
      NLP::Tokenizer.is_number?("12abc").should be_false
    end

    it "identifies punctuation correctly" do
      NLP::Tokenizer.is_punctuation?(".").should be_true
      NLP::Tokenizer.is_punctuation?("!").should be_true
      NLP::Tokenizer.is_punctuation?("?").should be_true
      NLP::Tokenizer.is_punctuation?(",").should be_true
      NLP::Tokenizer.is_punctuation?(":").should be_true
      NLP::Tokenizer.is_punctuation?(";").should be_true
      NLP::Tokenizer.is_punctuation?("hello").should be_false
    end

    it "classifies token types correctly" do
      NLP::Tokenizer.get_token_type("hello").should eq("word")
      NLP::Tokenizer.get_token_type("123").should eq("number")
      NLP::Tokenizer.get_token_type(".").should eq("punctuation")
      NLP::Tokenizer.get_token_type("@#$").should eq("other")
    end
  end

  describe "advanced tokenization" do
    it "provides tokens with features" do
      text = "Hello world 123"
      features = NLP::Tokenizer.tokenize_with_features(text)

      features.size.should eq(3)
      features[0][:token].should eq("hello")
      features[0][:type].should eq("word")
      features[0][:position].should eq(0)

      features[1][:token].should eq("world")
      features[1][:type].should eq("word")
      features[1][:position].should eq(1)

      features[2][:token].should eq("123")
      features[2][:type].should eq("number")
      features[2][:position].should eq(2)
    end

    it "handles contractions" do
      # Test basic contraction handling in token cleaning
      text = "can't won't"
      tokens = NLP::Tokenizer.tokenize(text)

      # Should handle contractions (implementation may normalize them)
      tokens.size.should be >= 2
    end
  end

  describe "token statistics" do
    it "calculates correct statistics" do
      tokens = ["hello", "world", "123", ".", "foo", "456"]
      stats = NLP::Tokenizer.get_token_stats(tokens)

      stats["total_tokens"].should eq(6)
      stats["unique_tokens"].should eq(6)
      stats["words"].should eq(3)       # hello, world, foo
      stats["numbers"].should eq(2)     # 123, 456
      stats["punctuation"].should eq(1) # .
      stats["other"].should eq(0)
    end

    it "handles empty token array" do
      tokens = [] of String
      stats = NLP::Tokenizer.get_token_stats(tokens)

      stats["total_tokens"].should eq(0)
      stats["unique_tokens"].should eq(0)
      stats["words"].should eq(0)
      stats["numbers"].should eq(0)
      stats["punctuation"].should eq(0)
      stats["other"].should eq(0)
    end

    it "counts duplicate tokens correctly" do
      tokens = ["hello", "hello", "world"]
      stats = NLP::Tokenizer.get_token_stats(tokens)

      stats["total_tokens"].should eq(3)
      stats["unique_tokens"].should eq(2) # hello, world (hello appears twice)
    end
  end

  describe "edge cases" do
    it "handles single character input" do
      text = "a"
      tokens = NLP::Tokenizer.tokenize(text)

      tokens.should eq(["a"])
    end

    it "handles input with only punctuation" do
      text = "..."
      tokens = NLP::Tokenizer.tokenize(text)

      # Should handle gracefully, may produce empty result or cleaned tokens
      tokens.should be_a(Array(String))
    end

    it "handles mixed case and numbers" do
      text = "Hello123 World456"
      tokens = NLP::Tokenizer.tokenize(text)

      # Should handle mixed content
      tokens.size.should be >= 2
    end
  end
end
