# MOSES Optimization Framework

The MOSES (Meta-Optimizing Semantic Evolutionary Search) optimization framework provides a high-level interface for evolutionary program learning in Crystal.

## Overview

MOSES is an evolutionary program learner that uses genetic programming techniques to evolve programs that fit given datasets or solve problems. This Crystal implementation provides both a low-level `Moses` module and a high-level `MOSES` framework module.

## Features

- **Multiple Problem Types**: Boolean classification, regression, clustering, pattern mining, feature selection
- **Evolutionary Algorithms**: Genetic algorithms, hill climbing, simulated annealing, ensemble optimization
- **Deme-Based Evolution**: Population subdivision for improved exploration
- **Metapopulation Management**: Best candidate tracking across evolutionary runs
- **Flexible Scoring**: Pluggable fitness functions for different problem domains
- **AtomSpace Integration**: Works with OpenCog's knowledge representation system

## Quick Start

### Basic Usage

```crystal
require "./src/moses/moses_framework"

# Initialize the framework
MOSES.initialize

# Create optimization parameters for boolean classification (XOR problem)
training_data = [
  [0.0, 0.0],
  [0.0, 1.0], 
  [1.0, 0.0],
  [1.0, 1.0]
]
target_data = [0.0, 1.0, 1.0, 0.0]  # XOR outputs

params = MOSES.boolean_params(training_data, target_data, max_evals: 500)

# Run optimization
result = MOSES.optimize(params)

# Examine results
puts "Best score: #{result.best_score}"
puts "Evaluations: #{result.evaluations}"
puts "Generations: #{result.generations}"

result.candidates.first(5).each_with_index do |candidate, i|
  puts "#{i + 1}. #{candidate.program} (score: #{candidate.score})"
end
```

### Advanced Usage with Optimizer Class

```crystal
# Create an optimizer with custom parameters
params = Moses::MosesParams.new(
  problem_type: Moses::ProblemType::Regression,
  training_data: regression_data,
  target_data: regression_targets,
  max_evals: 1000,
  max_gens: 50,
  population_size: 100,
  deme_size: 20
)

optimizer = MOSES.create_optimizer(params)

# Run optimization
result = optimizer.optimize

# Get statistics during optimization
stats = optimizer.statistics
puts "Mean score: #{stats["mean_score"]}"
puts "Diversity: #{stats["diversity"]}"

# Get best candidates
best_candidates = optimizer.best_candidates(10)
```

### Integration with AtomSpace

```crystal
# Initialize systems
CogUtil.initialize
AtomSpace.initialize
MOSES.initialize

# Create AtomSpace and optimizer
atomspace = AtomSpace.create_atomspace
optimizer = MOSES.create_optimizer(params, atomspace)

# The optimizer can now work with AtomSpace knowledge
result = optimizer.optimize
```

## API Reference

### MOSES Module Methods

#### `MOSES.initialize`
Initialize the MOSES framework and dependencies.

#### `MOSES.create_optimizer(atomspace = nil) : Optimizer`
Create an optimizer with default parameters.

#### `MOSES.create_optimizer(params, atomspace = nil) : Optimizer`
Create an optimizer with custom parameters.

#### `MOSES.optimize(params) : MosesResult`
Run optimization with the given parameters and return results.

#### `MOSES.create_metapopulation(params) : MetaPopulation`
Create a metapopulation for evolutionary search.

#### `MOSES.create_scorer(problem_type, training_data, target_data = nil) : ScoringFunction`
Create a scoring function for the given problem type and data.

#### `MOSES.boolean_params(training_data, target_data, max_evals = 500) : MosesParams`
Create optimization parameters for boolean classification problems.

#### `MOSES.regression_params(training_data, target_data, max_evals = 300) : MosesParams`
Create optimization parameters for regression problems.

#### `MOSES.info : Hash(String, String)`
Get information about the framework.

### Optimizer Class

#### `optimizer.optimize : MosesResult`
Run the optimization process and return results.

#### `optimizer.best_candidates(count = 10) : Array(Candidate)`
Get the current best candidates.

#### `optimizer.statistics : Hash(String, Float64)`
Get optimization statistics (mean score, best score, diversity, etc.).

## Configuration

### Problem Types

- `Moses::ProblemType::BooleanClassification` - Learn boolean functions
- `Moses::ProblemType::Regression` - Learn continuous functions  
- `Moses::ProblemType::Clustering` - Find data clustering patterns
- `Moses::ProblemType::PatternMining` - Discover patterns in data
- `Moses::ProblemType::FeatureSelection` - Select relevant features

### Optimization Parameters

```crystal
Moses::MosesParams.new(
  problem_type: Moses::ProblemType::BooleanClassification,
  training_data: data_array,           # Array(Array(Float64))
  target_data: target_array,           # Array(Float64)? 
  max_evals: 10000,                    # Maximum function evaluations
  max_gens: 100,                       # Maximum generations
  population_size: 100,                # Metapopulation size
  deme_size: 20,                       # Deme (subpopulation) size
  complexity_penalty: 0.1,             # Penalty for complex programs
  uniformity_penalty: 0.0              # Penalty for uniform populations
)
```

## Architecture

The MOSES framework consists of several key components:

1. **MetaPopulation**: Manages the collection of best candidates across all evolutionary runs
2. **Deme**: Subpopulations that explore specific regions of the program space
3. **ScoringFunction**: Evaluates candidate programs for fitness
4. **Representation**: Handles program encoding, mutation, and crossover
5. **Optimization**: Contains various optimization algorithms (GA, HC, SA)

## Examples

### XOR Function Learning

```crystal
# XOR truth table
training_data = [[0.0, 0.0], [0.0, 1.0], [1.0, 0.0], [1.0, 1.0]]
target_data = [0.0, 1.0, 1.0, 0.0]

params = MOSES.boolean_params(training_data, target_data)
result = MOSES.optimize(params)

puts "Learned XOR function: #{result.best_candidate.try(&.program)}"
```

### Linear Regression

```crystal
# y = 2x + 1
training_data = (0..10).map { |x| [x.to_f] }
target_data = training_data.map { |input| 2.0 * input[0] + 1.0 }

params = MOSES.regression_params(training_data, target_data)
result = MOSES.optimize(params)

puts "Learned function: #{result.best_candidate.try(&.program)}"
```

## Performance Considerations

- Increase `population_size` for more thorough search at the cost of memory
- Increase `deme_size` for better local search within program neighborhoods  
- Adjust `max_evals` based on problem complexity and available computation time
- Use `complexity_penalty` to favor simpler programs
- Monitor `diversity` statistics to ensure population doesn't converge prematurely

## Integration with OpenCog

The MOSES framework integrates seamlessly with other OpenCog components:

- **AtomSpace**: Store and retrieve evolved programs as Atomese expressions
- **PLN**: Use probabilistic logic networks for reasoning about program candidates
- **Pattern Matching**: Find and reuse successful program patterns
- **CogServer**: Expose MOSES optimization as a service

## Error Handling

The framework includes comprehensive error handling:

- `Moses::MosesException` - Base class for MOSES-related errors
- `Moses::EvolutionException` - Errors during evolutionary process
- `Moses::ScoringException` - Errors in fitness evaluation
- `Moses::RepresentationException` - Errors in program representation

## Debugging and Logging

Enable debug logging to monitor the optimization process:

```crystal
CogUtil::Logger.set_level(CogUtil::Logger::DEBUG)
MOSES.initialize

# Now optimization will produce detailed debug output
result = MOSES.optimize(params)
```

## Contributing

The MOSES framework is part of the larger OpenCog project. Contributions are welcome:

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Submit a pull request with detailed description

## References

- [MOSES Original Paper](https://link.springer.com/chapter/10.1007/978-3-540-78293-3_21)
- [OpenCog Documentation](https://opencog.org/documentation/)
- [Crystal Language](https://crystal-lang.org/)
- [Evolutionary Computation](https://en.wikipedia.org/wiki/Evolutionary_computation)