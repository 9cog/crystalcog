# Natural Language Processing main entry point
#
# This provides a standalone interface to the NLP module
# for testing and demonstration purposes.

require "./nlp"

module NLPMain
  def self.main(args = ARGV)
    puts "CrystalCog NLP Module #{NLP::VERSION}"
    puts "=============================="

    # Initialize required systems
    CogUtil.initialize
    AtomSpace.initialize
    NLP.initialize

    case args.first?
    when "demo"
      run_demo
    when "tokenize"
      if args.size < 2
        puts "Usage: nlp tokenize \"text to tokenize\""
        return
      end
      tokenize_text(args[1])
    when "process"
      if args.size < 2
        puts "Usage: nlp process \"text to process\""
        return
      end
      process_text(args[1])
    when "stats"
      if args.size < 2
        puts "Usage: nlp stats \"text to analyze\""
        return
      end
      analyze_text(args[1])
    else
      puts "Usage: nlp [demo|tokenize|process|stats] [text]"
      puts "  demo      - Run comprehensive NLP demonstration"
      puts "  tokenize  - Tokenize the provided text"
      puts "  process   - Process text into AtomSpace representation"
      puts "  stats     - Show detailed text statistics"
    end
  end

  private def self.run_demo
    puts "\nRunning NLP Demonstration..."

    atomspace = AtomSpace::AtomSpace.new

    # Create linguistic knowledge base
    puts "\n1. Creating linguistic knowledge base..."
    NLP.create_linguistic_kb(atomspace)
    puts "   Created #{atomspace.size} base linguistic atoms"

    # Process sample texts
    puts "\n2. Processing sample texts..."
    texts = [
      "The quick brown fox jumps over the lazy dog.",
      "Natural language processing enables computers to understand human language.",
      "Crystal is a statically typed programming language.",
    ]

    texts.each_with_index do |text, i|
      puts "\n   Text #{i + 1}: #{text}"

      # Tokenization
      tokens = NLP::Tokenizer.tokenize(text)
      puts "   Tokens (#{tokens.size}): #{tokens.join(", ")}"

      # Process into atoms
      atoms = NLP.process_text(text, atomspace)
      puts "   Created #{atoms.size} linguistic atoms"

      # Text statistics
      stats = NLP::TextProcessor.get_text_stats(text)
      puts "   Words: #{stats["word_count"]}, Sentences: #{stats["sentence_count"]}"

      # Keywords
      keywords = NLP::TextProcessor.extract_keywords(text, 3)
      puts "   Keywords: #{keywords.join(", ")}"
    end

    # Create semantic relationships
    puts "\n3. Creating semantic relationships..."
    NLP::LinguisticAtoms.create_semantic_relation(atomspace, "fox", "animal", "isa", 0.9)
    NLP::LinguisticAtoms.create_semantic_relation(atomspace, "dog", "animal", "isa", 0.9)
    NLP::LinguisticAtoms.create_semantic_relation(atomspace, "quick", "fast", "synonym", 0.8)

    lexical_atoms = NLP::LinguisticAtoms.create_lexical_relations(atomspace)
    puts "   Added #{lexical_atoms.size} lexical relations"

    # Final statistics
    puts "\n4. Final AtomSpace Analysis..."
    puts "   Total atoms: #{atomspace.size}"

    linguistic_stats = NLP.get_linguistic_stats(atomspace)
    puts "   Word atoms: #{linguistic_stats["word_atoms"]}"
    puts "   Sentence atoms: #{linguistic_stats["sentence_atoms"]}"

    complexity = NLP::LinguisticAtoms.get_linguistic_complexity(atomspace)
    puts "   Evaluation links: #{complexity["evaluation_links"]}"
    puts "   List links: #{complexity["list_links"]}"
    puts "   Inheritance links: #{complexity["inheritance_links"]}"

    puts "\nNLP demonstration completed successfully!"
  end

  private def self.tokenize_text(text)
    puts "\nTokenizing: \"#{text}\""
    puts "=" * 40

    # Basic tokenization
    tokens = NLP::Tokenizer.tokenize(text)
    puts "Tokens: #{tokens.join(" | ")}"

    # Token statistics
    stats = NLP::Tokenizer.get_token_stats(tokens)
    puts "\nToken Statistics:"
    stats.each { |key, value| puts "  #{key}: #{value}" }

    # Token features
    features = NLP::Tokenizer.tokenize_with_features(text)
    puts "\nToken Features:"
    features.each do |feature|
      puts "  #{feature[:position] + 1}. #{feature[:token]} (#{feature[:type]})"
    end

    # Sentence splitting
    sentences = NLP::Tokenizer.split_sentences(text)
    if sentences.size > 1
      puts "\nSentences:"
      sentences.each_with_index do |sentence, i|
        puts "  #{i + 1}. #{sentence}"
      end
    end
  end

  private def self.process_text(text)
    puts "\nProcessing: \"#{text}\""
    puts "=" * 40

    atomspace = AtomSpace::AtomSpace.new

    # Process text
    atoms = NLP.process_text(text, atomspace)
    puts "Created #{atoms.size} atoms in AtomSpace"

    # Show atom details
    puts "\nCreated Atoms:"
    atoms.each_with_index do |atom, i|
      puts "  #{i + 1}. #{atom.class.name}: #{atom.name}"
    end

    # Show linguistic structure
    word_atoms = NLP::LinguisticAtoms.get_word_atoms(atomspace)
    sentence_atoms = NLP::LinguisticAtoms.get_sentence_atoms(atomspace)

    puts "\nLinguistic Structure:"
    puts "  Word atoms: #{word_atoms.size}"
    puts "  Sentence atoms: #{sentence_atoms.size}"
    puts "  Total AtomSpace size: #{atomspace.size}"
  end

  private def self.analyze_text(text)
    puts "\nAnalyzing: \"#{text}\""
    puts "=" * 40

    # Text statistics
    stats = NLP::TextProcessor.get_text_stats(text)
    puts "Text Statistics:"
    stats.each { |key, value| puts "  #{key}: #{value}" }

    # Tokenization analysis
    tokens = NLP::Tokenizer.tokenize(text)
    token_stats = NLP::Tokenizer.get_token_stats(tokens)
    puts "\nTokenization Analysis:"
    token_stats.each { |key, value| puts "  #{key}: #{value}" }

    # Preprocessing
    normalized = NLP::TextProcessor.normalize_text(text)
    puts "\nText Preprocessing:"
    puts "  Original: #{text}"
    puts "  Normalized: #{normalized}"

    # Stop word removal
    filtered_tokens = NLP::TextProcessor.remove_stop_words(tokens)
    puts "  Tokens after stop word removal: #{filtered_tokens.join(", ")}"

    # Stemming
    stemmed = NLP::TextProcessor.stem_tokens(filtered_tokens)
    puts "  Stemmed tokens: #{stemmed.join(", ")}"

    # Keywords
    keywords = NLP::TextProcessor.extract_keywords(text, 5)
    puts "  Top keywords: #{keywords.join(", ")}"

    # N-grams
    if tokens.size >= 2
      bigrams = NLP::TextProcessor.extract_ngrams(tokens, 2)
      puts "  Bigrams: #{bigrams.map { |bg| bg.join("-") }.join(", ")}"
    end

    # Term frequency
    tf = NLP::TextProcessor.calculate_term_frequency(tokens)
    puts "\nTerm Frequencies:"
    tf.to_a.sort_by { |_, freq| -freq }.first(5).each do |term, freq|
      puts "  #{term}: #{(freq * 100).round(1)}%"
    end
  end
end

# Run if executed directly
if PROGRAM_NAME == __FILE__
  NLPMain.main(ARGV)
end
