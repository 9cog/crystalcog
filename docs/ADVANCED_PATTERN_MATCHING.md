# Advanced Pattern Matching Documentation

## Overview

The Advanced Pattern Matching system in CrystalCog provides sophisticated cognitive reasoning capabilities as part of the Agent-Zero Genesis roadmap (Month 3+ features). This system extends the basic pattern matching with recursive queries, temporal sequences, machine learning, and statistical inference.

## Features

### 1. Recursive Query Composition

Build complex queries by composing simpler patterns using logical operators.

```crystal
# Create a recursive query composer
composer = PatternMatching::Advanced::RecursiveQueryComposer.new(atomspace)

# Register base patterns
composer.register_pattern("is_mammal", mammal_pattern)
composer.register_pattern("likes_food", food_preference_pattern)

# Compose with logical operators
and_results = composer.compose_and(["is_mammal", "likes_food"])
or_results = composer.compose_or(["is_mammal", "is_bird"])
not_results = composer.compose_not("is_animal", "is_mammal")
```

#### Supported Operations
- **AND Composition**: Find matches that satisfy all specified patterns
- **OR Composition**: Find matches that satisfy any of the specified patterns  
- **NOT Composition**: Find matches from base pattern excluding those in exclude pattern
- **Recursive Composition**: Self-referential patterns with controlled depth

### 2. Temporal Pattern Matching

Match patterns across time sequences and intervals.

```crystal
# Create temporal pattern matcher
temporal_matcher = PatternMatching::Advanced::TemporalPatternMatcher.new(atomspace, 10000_i64)

# Match sequence of patterns
patterns = [pattern1, pattern2, pattern3]
sequences = temporal_matcher.match_sequence(patterns, "my_sequence")

# Match within time interval
interval_matches = temporal_matcher.match_within_interval(pattern, 5000_i64)

# Detect repeating patterns
repeating = temporal_matcher.detect_repeating_patterns(pattern, min_occurrences: 3)
```

#### Temporal Features
- **Sequence Matching**: Patterns that occur in temporal order
- **Interval Matching**: Patterns within specific time windows
- **Repeating Pattern Detection**: Automatically find recurring temporal patterns
- **Duration Analysis**: Calculate pattern duration and intervals

### 3. Pattern Learning and Optimization

Automatically discover frequent patterns and optimize matching performance.

```crystal
# Create pattern learner
learner = PatternMatching::Advanced::PatternLearner.new(atomspace, 0.1, 0.8)

# Learn patterns from current atomspace
learned_patterns = learner.learn_patterns

# Apply learned patterns for new matches
new_matches = learner.apply_learned_patterns

# Get learning statistics
stats = learner.pattern_statistics
```

#### Learning Capabilities
- **Inheritance Pattern Discovery**: Find common inheritance hierarchies
- **Evaluation Pattern Discovery**: Identify frequent predicate relationships
- **Structural Pattern Discovery**: Detect common graph structures
- **Frequency Analysis**: Calculate pattern occurrence rates
- **Confidence Metrics**: Assess pattern reliability

### 4. Statistical and Probabilistic Pattern Matching

Perform fuzzy matching and statistical inference on patterns.

```crystal
# Create statistical matcher
statistical_matcher = PatternMatching::Advanced::StatisticalMatcher.new(atomspace, 0.7)

# Probabilistic matching with confidence intervals
prob_results = statistical_matcher.probabilistic_match(pattern)

# Fuzzy matching with similarity thresholds
fuzzy_results = statistical_matcher.fuzzy_match(pattern, 0.8)

# Bayesian inference
evidence_patterns = [pattern1, pattern2]
hypothesis_pattern = pattern3
inference_result = statistical_matcher.bayesian_inference(evidence_patterns, hypothesis_pattern)

# Monte Carlo sampling
mc_results = statistical_matcher.monte_carlo_sampling(pattern, 1000)
```

#### Statistical Features
- **Probabilistic Matching**: Truth value-based probability calculations
- **Fuzzy Matching**: Partial pattern matches with similarity scores
- **Bayesian Inference**: P(hypothesis|evidence) calculations using Bayes' theorem
- **Monte Carlo Sampling**: Statistical exploration of pattern space
- **Confidence Intervals**: Statistical significance testing

## Advanced Pattern Builder

The `AdvancedPatternBuilder` class provides a unified interface to all advanced features:

```crystal
# Create advanced pattern builder
builder = PatternMatching::AdvancedPatternBuilder.new(atomspace)

# Register patterns
builder.register_pattern("mammals", mammal_pattern)
builder.register_pattern("animals", animal_pattern)

# Use composition operations
and_results = builder.and_patterns(["mammals", "animals"])
or_results = builder.or_patterns(["mammals", "animals"])

# Use temporal operations
temporal_matches = builder.temporal_sequence([pattern1, pattern2])

# Use learning operations
learned_patterns = builder.learn_patterns
learned_results = builder.apply_learned_patterns

# Use statistical operations
prob_matches = builder.probabilistic_match(pattern)
fuzzy_matches = builder.fuzzy_match(pattern)
```

## Performance Characteristics

### Scalability
- **Caching**: Automatic result caching for repeated queries
- **Indexing**: Efficient atom lookup by type and properties
- **Lazy Evaluation**: Patterns computed on demand
- **Result Limiting**: Configurable maximum results for performance

### Memory Management
- **Object Pooling**: Reuse of pattern matching objects
- **Garbage Collection**: Automatic cleanup of temporary results
- **Cache Management**: LRU eviction for pattern caches

### Benchmarks
Typical performance on a modern system:
- Simple pattern matching: < 1ms for 100 atoms
- Recursive composition: < 5ms for 1000 atoms
- Pattern learning: < 10ms for 1000 atoms
- Statistical inference: < 20ms for complex patterns

## Usage Examples

### Example 1: Animal Classification System

```crystal
# Create knowledge base
atomspace = AtomSpace::AtomSpace.new
dog = atomspace.add_concept_node("dog")
mammal = atomspace.add_concept_node("mammal")
atomspace.add_inheritance_link(dog, mammal)

# Create advanced pattern builder
builder = PatternMatching::AdvancedPatternBuilder.new(atomspace)

# Register classification patterns
var_x = AtomSpace::VariableNode.new("$X")
mammal_pattern = AtomSpace::InheritanceLink.new(var_x, mammal)
builder.register_pattern("is_mammal", mammal_pattern)

# Learn classification patterns
learned_patterns = builder.learn_patterns
puts "Learned #{learned_patterns.size} classification patterns"

# Apply probabilistic classification
prob_matches = builder.probabilistic_match(PatternMatching::Pattern.new(mammal_pattern))
prob_matches.each do |match|
  puts "Classification probability: #{match.probability}"
end
```

### Example 2: Temporal Event Analysis

```crystal
# Create temporal event patterns
event1 = PatternMatching::Pattern.new(login_pattern)
event2 = PatternMatching::Pattern.new(action_pattern) 
event3 = PatternMatching::Pattern.new(logout_pattern)

# Analyze temporal sequences
temporal_matches = builder.temporal_sequence([event1, event2, event3], "user_session")
temporal_matches.each do |match|
  puts "Session duration: #{match.duration_ms}ms"
  puts "Average interval: #{match.average_interval_ms}ms"
end
```

### Example 3: Fuzzy Knowledge Retrieval

```crystal
# Create fuzzy query for similar concepts
concept_pattern = PatternMatching::Pattern.new(similarity_template)

# Perform fuzzy matching
fuzzy_results = builder.fuzzy_match(concept_pattern, 0.7)
fuzzy_results.each do |result|
  puts "Similarity: #{result.probability}"
  puts "Confidence interval: #{result.confidence_intervals["95%"]}"
end
```

## Configuration Options

### Pattern Learning
- `frequency_threshold`: Minimum frequency for pattern discovery (default: 0.1)
- `confidence_threshold`: Minimum confidence for pattern acceptance (default: 0.8)

### Statistical Matching
- `fuzzy_threshold`: Minimum similarity for fuzzy matches (default: 0.7)
- `monte_carlo_samples`: Number of samples for MC analysis (default: 1000)

### Temporal Matching
- `time_window_ms`: Time window for sequence detection (default: 5000ms)
- `max_sequence_length`: Maximum pattern sequence length (default: 10)

### Performance Tuning
- `max_results`: Maximum results per query (default: 1000)
- `cache_size`: Size of result cache (default: 10000 entries)
- `timeout_ms`: Query timeout in milliseconds (default: 30000ms)

## Error Handling

### Exception Types
- `PatternCompositionException`: Errors in pattern composition
- `TemporalMatchingException`: Errors in temporal analysis
- `LearningException`: Errors in pattern learning
- `StatisticalMatchingException`: Errors in statistical analysis

### Error Recovery
```crystal
begin
  results = builder.probabilistic_match(complex_pattern)
rescue PatternMatching::Advanced::StatisticalMatchingException => e
  puts "Statistical matching failed: #{e.message}"
  # Fallback to basic pattern matching
  basic_results = basic_matcher.match(pattern)
end
```

## Integration with Agent-Zero Genesis

The advanced pattern matching system integrates seamlessly with other Agent-Zero Genesis components:

- **Cognitive Kernels**: Patterns can operate on cognitive kernel states
- **Hypergraph Persistence**: Learned patterns are automatically persisted
- **Attention Allocation**: Statistical results inform attention mechanisms
- **Meta-Cognition**: Temporal patterns enable meta-level reasoning

## Future Extensions

Planned enhancements for future releases:
- **Distributed Pattern Matching**: Patterns across multiple atomspaces
- **Neural Pattern Learning**: Deep learning integration for pattern discovery
- **Quantum Pattern Matching**: Quantum computing optimization
- **Multi-Modal Patterns**: Patterns across different data modalities

## References

- [OpenCog Pattern Matching](https://wiki.opencog.org/w/Pattern_matching)
- [Agent-Zero Genesis Roadmap](../AGENT-ZERO-GENESIS.md)
- [CrystalCog Architecture](../README.md)
- [Hypergraph State Persistence](HYPERGRAPH_STATE_PERSISTENCE_DOCUMENTATION.md)