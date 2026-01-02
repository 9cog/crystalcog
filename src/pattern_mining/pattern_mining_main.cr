# Main entry point for Pattern Mining module
# This provides a command-line interface for pattern mining operations

require "./pattern_mining"

module PatternMining
  # Initialize the pattern mining system
  def self.initialize
    CogUtil::Logger.info("Initializing Pattern Mining system v#{VERSION}")
    true
  end

  # Create a pattern miner with default settings
  def self.create_miner(atomspace : AtomSpace::AtomSpace, min_support : Int32 = 2) : PatternMiner
    PatternMiner.new(atomspace, min_support)
  end

  # Mine patterns from an atomspace with convenient defaults
  def self.mine(atomspace : AtomSpace::AtomSpace, min_support : Int32 = 2,
                max_patterns : Int32 = 100, timeout_seconds : Int32? = 30) : MiningResult
    miner = PatternMiner.new(atomspace, min_support, max_patterns, timeout_seconds)
    miner.mine_patterns
  end

  # Demonstrate pattern mining with a simple example
  def self.demo
    puts "Pattern Mining Demo"
    puts "=================="

    # Create an atomspace with some sample data
    atomspace = AtomSpace::AtomSpace.new

    # Add some sample knowledge
    dog = atomspace.add_concept_node("dog")
    cat = atomspace.add_concept_node("cat")
    animal = atomspace.add_concept_node("animal")
    mammal = atomspace.add_concept_node("mammal")

    # Add inheritance relationships
    atomspace.add_inheritance_link(dog, mammal)
    atomspace.add_inheritance_link(cat, mammal)
    atomspace.add_inheritance_link(mammal, animal)

    # Add some evaluation links
    likes = atomspace.add_predicate_node("likes")
    john = atomspace.add_concept_node("john")
    mary = atomspace.add_concept_node("mary")

    atomspace.add_evaluation_link(likes, AtomSpace::ListLink.new([john, dog]))
    atomspace.add_evaluation_link(likes, AtomSpace::ListLink.new([mary, cat]))

    puts "Created atomspace with #{atomspace.size} atoms"

    # Mine patterns
    puts "\nMining patterns with min_support=2..."
    result = mine(atomspace, min_support: 2, max_patterns: 50, timeout_seconds: 10)

    puts "Mining completed: #{result}"
    puts "\nFrequent patterns found:"
    frequent = result.frequent_patterns(2)
    frequent.each_with_index do |pattern_support, i|
      puts "  #{i + 1}. #{pattern_support}"
    end

    if frequent.empty?
      puts "  No frequent patterns found with min_support=2"
      puts "  Trying with min_support=1..."
      frequent = result.frequent_patterns(1)
      frequent.each_with_index do |pattern_support, i|
        puts "  #{i + 1}. #{pattern_support}"
      end
    end
  end
end

# Run demo if this file is executed directly
if PROGRAM_NAME.includes?("pattern_mining_main")
  PatternMining.initialize
  PatternMining.demo
end
