#!/usr/bin/env crystal

# MOSES Optimization Framework Demo
# This script demonstrates the usage of the MOSES framework for evolutionary program learning

require "../src/moses/moses_framework"

puts "=" * 60
puts "MOSES Optimization Framework Demo"
puts "=" * 60

# Initialize the framework
puts "\n1. Initializing MOSES framework..."
MOSES.initialize

# Show framework information
info = MOSES.info
puts "   Version: #{info["version"]}"
puts "   Description: #{info["description"]}"
puts "   Algorithms: #{info["algorithms"]}"

# Example 1: Boolean Classification (XOR Function)
puts "\n2. Boolean Classification Example - Learning XOR Function"
puts "   " + "-" * 50

# XOR truth table
training_data = [
  [0.0, 0.0],
  [0.0, 1.0], 
  [1.0, 0.0],
  [1.0, 1.0]
]
target_data = [0.0, 1.0, 1.0, 0.0]  # XOR outputs

puts "   Training data (XOR function):"
training_data.each_with_index do |input, i|
  puts "     #{input} -> #{target_data[i]}"
end

# Create parameters and run optimization
puts "   \n   Running MOSES optimization..."
params = MOSES.boolean_params(training_data, target_data, max_evals: 100)
result = MOSES.optimize(params)

puts "   \n   Results:"
puts "     Evaluations: #{result.evaluations}"
puts "     Generations: #{result.generations}" 
puts "     Best score: #{result.best_score.try(&.penalized_score)}"

puts "   \n   Top candidates:"
result.candidates[0...3].each_with_index do |candidate, i|
  puts "     #{i + 1}. #{candidate.program} (score: #{candidate.score.try(&.penalized_score)})"
end

# Example 2: Regression (Linear Function)
puts "\n3. Regression Example - Learning Linear Function"
puts "   " + "-" * 50

# y = 2*x + 1 
regression_training_data = (0..5).map { |x| [x.to_f] }.to_a
regression_target_data = regression_training_data.map { |input| 2.0 * input[0] + 1.0 }

puts "   Training data (y = 2*x + 1):"
regression_training_data[0...4].each_with_index do |input, i|
  puts "     x=#{input[0]} -> y=#{regression_target_data[i]}"
end
puts "     ..."

puts "   \n   Running MOSES optimization..."
regression_params = MOSES.regression_params(regression_training_data, regression_target_data, max_evals: 50)
regression_result = MOSES.optimize(regression_params)

puts "   \n   Results:"
puts "     Evaluations: #{regression_result.evaluations}"
puts "     Generations: #{regression_result.generations}"
puts "     Best score: #{regression_result.best_score.try(&.penalized_score)}"

puts "   \n   Top candidates:"
regression_result.candidates[0...3].each_with_index do |candidate, i|
  puts "     #{i + 1}. #{candidate.program} (score: #{candidate.score.try(&.penalized_score)})"
end

# Example 3: Advanced Usage with Optimizer Class
puts "\n4. Advanced Usage - Using Optimizer Class"
puts "   " + "-" * 50

# Create custom parameters
custom_params = Moses::MosesParams.new(
  problem_type: Moses::ProblemType::BooleanClassification,
  training_data: training_data,
  target_data: target_data,
  max_evals: 75,
  max_gens: 10,
  population_size: 15,
  deme_size: 5
)

puts "   Creating optimizer with custom parameters:"
puts "     Problem type: Boolean Classification"
puts "     Max evaluations: #{custom_params.max_evals}"
puts "     Population size: #{custom_params.population_size}"
puts "     Deme size: #{custom_params.deme_size}"

optimizer = MOSES.create_optimizer(custom_params)
puts "   Optimizer created: #{optimizer.class}"

puts "   \n   Running optimization..."
optimizer_result = optimizer.optimize

puts "   \n   Statistics during optimization:"
stats = optimizer.statistics
stats.each do |key, value|
  puts "     #{key.capitalize}: #{value.round(4)}"
end

puts "   \n   Best candidates from optimizer:"
optimizer.best_candidates(3).each_with_index do |candidate, i|
  puts "     #{i + 1}. #{candidate.program} (score: #{candidate.score.try(&.penalized_score)})"
end

# Example 4: Integration with AtomSpace
puts "\n5. AtomSpace Integration Example"
puts "   " + "-" * 50

begin
  # Initialize dependencies
  CogUtil.initialize
  AtomSpace.initialize
  
  puts "   Creating AtomSpace..."
  atomspace = AtomSpace.create_atomspace
  puts "   AtomSpace created: #{atomspace.class}"
  
  puts "   Creating optimizer with AtomSpace integration..."
  atomspace_optimizer = MOSES.create_optimizer(params, atomspace)
  puts "   Integrated optimizer created successfully"
  
rescue ex
  puts "   AtomSpace integration: #{ex.message} (this is expected in demo mode)"
end

# Example 5: Framework Component Overview
puts "\n6. Framework Components Overview"
puts "   " + "-" * 50

puts "   Available scoring functions:"
puts "     - BooleanTableScoring: For boolean classification problems"
puts "     - RegressionScoring: For continuous function approximation"
puts "     - ClusteringScoring: For unsupervised clustering tasks"

puts "   \n   Available optimization algorithms:"
puts "     - Genetic Algorithm: Population-based evolutionary search"
puts "     - Hill Climbing: Local gradient-based optimization"  
puts "     - Simulated Annealing: Probabilistic local search"
puts "     - Ensemble Optimizer: Combines multiple algorithms"

puts "   \n   Key data structures:"
puts "     - Candidate: Represents an evolved program with score"
puts "     - MetaPopulation: Manages best candidates across runs"
puts "     - Deme: Subpopulation for local search"
puts "     - MosesParams: Configuration for optimization run"

# Summary
puts "\n" + "=" * 60
puts "MOSES Framework Demo Complete!"
puts "=" * 60

puts "\nThe MOSES optimization framework provides:"
puts "• High-level API for evolutionary program learning"
puts "• Multiple problem types (classification, regression, clustering)"
puts "• Flexible optimization algorithms and parameters"
puts "• Integration with OpenCog AtomSpace"
puts "• Comprehensive documentation and examples"

puts "\nNext steps:"
puts "• Try modifying the parameters to see different results"
puts "• Experiment with different problem types"
puts "• Integrate with your own datasets"
puts "• Explore the underlying Moses module for advanced usage"

puts "\nFor more information, see docs/moses_framework.md"
puts "=" * 60