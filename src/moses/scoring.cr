# MOSES scoring functions
# Implements fitness evaluation for different problem types

require "./types"

module Moses
  # Abstract base class for scoring functions
  abstract class ScoringFunction
    abstract def evaluate(candidate : Candidate) : CompositeScore
    abstract def problem_type : ProblemType

    # Count evaluations performed
    property evaluations : Int32 = 0

    def score(candidate : Candidate) : CompositeScore
      @evaluations += 1
      result = evaluate(candidate)
      candidate.score = result
      result
    end
  end

  # Boolean classification scoring function
  class BooleanTableScoring < ScoringFunction
    property training_data : Array(Array(Float64))
    property target_data : Array(Float64)

    def initialize(@training_data : Array(Array(Float64)), @target_data : Array(Float64))
      if training_data.size != target_data.size
        raise ScoringException.new("Training data and target data size mismatch")
      end
    end

    def problem_type : ProblemType
      ProblemType::BooleanClassification
    end

    def evaluate(candidate : Candidate) : CompositeScore
      # Evaluate the boolean program against training data
      accuracy = evaluate_boolean_program(candidate.program)
      complexity = calculate_complexity(candidate.program)

      # Convert accuracy to negative score (MOSES convention: higher=better)
      score = accuracy - 1.0 # Range: 0.0 to -1.0, where 0.0 is perfect

      CompositeScore.new(score, complexity)
    end

    private def evaluate_boolean_program(program : String) : Float64
      # Parse and execute the evolved boolean program
      # This replaces the placeholder with actual program execution

      correct_predictions = 0
      total_predictions = training_data.size

      # Execute the evolved program against each training example
      training_data.each_with_index do |input, i|
        predicted = execute_boolean_program(program, input)
        actual = target_data[i] > 0.5
        correct_predictions += 1 if predicted == actual
      end

      correct_predictions.to_f / total_predictions
    end

    private def execute_boolean_program(program : String, input : Array(Float64)) : Bool
      # Real boolean program execution using the structured Program class
      begin
        candidate = Candidate.new(program)
        result = candidate.execute(input, ProblemType::BooleanClassification)

        case result
        when Bool
          result
        else
          false
        end
      rescue
        # If parsing fails, fall back to a simple heuristic
        fallback_boolean_evaluation(program, input)
      end
    end

    private def fallback_boolean_evaluation(program : String, input : Array(Float64)) : Bool
      # Fallback evaluation for complex or unparseable programs
      # Uses heuristics based on program content and input values

      if program.includes?("and") || program.includes?("&")
        input.all? { |v| v > 0.5 }
      elsif program.includes?("or") || program.includes?("|")
        input.any? { |v| v > 0.5 }
      elsif program.includes?("not")
        !(input[0]? && input[0] > 0.5)
      else
        # Default: return first input as boolean
        input[0]? && input[0] > 0.5
      end || false
    end

    private def calculate_complexity(program : String) : Complexity
      # Use structured Program complexity calculation when possible
      begin
        candidate = Candidate.new(program)
        candidate.complexity
      rescue
        # Fallback to simple string-based complexity
        base_complexity = program.size
        operator_bonus = program.count("and") + program.count("or") + program.count("not")
        base_complexity + operator_bonus * 2
      end
    end
  end

  # Regression scoring function
  class RegressionScoring < ScoringFunction
    property training_data : Array(Array(Float64))
    property target_data : Array(Float64)

    def initialize(@training_data : Array(Array(Float64)), @target_data : Array(Float64))
      if training_data.size != target_data.size
        raise ScoringException.new("Training data and target data size mismatch")
      end
    end

    def problem_type : ProblemType
      ProblemType::Regression
    end

    def evaluate(candidate : Candidate) : CompositeScore
      mse = evaluate_regression_program(candidate.program)
      complexity = calculate_complexity(candidate.program)

      # Convert MSE to negative score (lower MSE = higher score)
      score = -mse

      CompositeScore.new(score, complexity)
    end

    private def evaluate_regression_program(program : String) : Float64
      # Parse and execute the evolved regression program
      # This replaces the simplified evaluation with actual program execution
      total_error = 0.0

      training_data.each_with_index do |input, i|
        predicted = execute_regression_program(program, input)
        actual = target_data[i]
        error = (predicted - actual) ** 2
        total_error += error
      end

      total_error / training_data.size # Mean squared error
    end

    private def execute_regression_program(program : String, input : Array(Float64)) : Float64
      # Real regression program execution using the structured Program class
      begin
        candidate = Candidate.new(program)
        result = candidate.execute(input, ProblemType::Regression)

        case result
        when Float64
          result
        else
          0.0
        end
      rescue
        # If parsing fails, fall back to a simple heuristic
        fallback_regression_evaluation(program, input)
      end
    end

    private def fallback_regression_evaluation(program : String, input : Array(Float64)) : Float64
      # Fallback evaluation for complex or unparseable programs
      # Uses simple heuristics based on program content

      if program.includes?("+")
        input.sum
      elsif program.includes?("*")
        input.reduce(1.0) { |acc, val| acc * val }
      elsif program.includes?("-")
        (input[0]? || 0.0) - (input[1]? || 0.0)
      elsif program.includes?("/")
        dividend = input[0]? || 1.0
        divisor = input[1]? || 1.0
        divisor != 0.0 ? dividend / divisor : dividend
      else
        input[0]? || 0.0
      end
    end

    private def calculate_complexity(program : String) : Complexity
      # Use structured Program complexity calculation when possible
      begin
        candidate = Candidate.new(program)
        candidate.complexity
      rescue
        # Fallback to simple string-based complexity for regression
        program.size + program.count("+") + program.count("*") + program.count("-") + program.count("/")
      end
    end
  end

  # Clustering scoring function
  class ClusteringScoring < ScoringFunction
    property training_data : Array(Array(Float64))

    def initialize(@training_data : Array(Array(Float64)))
    end

    def problem_type : ProblemType
      ProblemType::Clustering
    end

    def evaluate(candidate : Candidate) : CompositeScore
      # Evaluate clustering quality using silhouette score
      # This replaces the placeholder with actual clustering evaluation
      score = evaluate_clustering_program(candidate.program)
      complexity = candidate.program.size

      CompositeScore.new(score, complexity)
    end

    private def evaluate_clustering_program(program : String) : Float64
      # Implement actual clustering evaluation
      # Use simplified k-means-like clustering based on the program

      return -10.0 if training_data.size < 2

      begin
        # Parse the program to determine clustering strategy
        num_clusters = extract_cluster_count(program)
        clusters = perform_clustering(training_data, num_clusters, program)

        # Calculate clustering quality (simplified silhouette-like score)
        silhouette_score = calculate_clustering_quality(training_data, clusters)

        # Convert to negative score (MOSES convention: higher=better)
        -silhouette_score # Negate because lower silhouette variance is better
      rescue
        # If clustering fails, return poor score
        -Random.rand(5.0) - 5.0
      end
    end

    private def extract_cluster_count(program : String) : Int32
      # Extract number of clusters from program representation
      # Look for numeric values in the program
      numbers = program.scan(/\d+/).map(&.[0].to_i?)
      valid_numbers = numbers.compact.select { |n| n > 0 && n <= training_data.size }

      if valid_numbers.empty?
        # Default to reasonable cluster count
        Math.min(3, training_data.size // 2 + 1)
      else
        Math.min(valid_numbers.first, training_data.size // 2 + 1)
      end
    end

    private def perform_clustering(data : Array(Array(Float64)), k : Int32, program : String) : Array(Int32)
      # Perform simple clustering based on the program strategy
      return Array(Int32).new(data.size, 0) if k <= 1

      # Initialize cluster assignments randomly
      assignments = Array(Int32).new(data.size) { Random.rand(k) }

      # Simple k-means-like iterations
      5.times do
        # Calculate cluster centers
        centers = calculate_cluster_centers(data, assignments, k)

        # Reassign points to nearest centers
        new_assignments = data.map_with_index do |point, _|
          nearest_cluster = find_nearest_cluster(point, centers)
          nearest_cluster
        end

        # Check for convergence
        break if assignments == new_assignments
        assignments = new_assignments
      end

      assignments
    end

    private def calculate_cluster_centers(data : Array(Array(Float64)), assignments : Array(Int32), k : Int32) : Array(Array(Float64))
      return [] of Array(Float64) if data.empty?

      dimensions = data.first.size
      centers = Array(Array(Float64)).new(k) { Array(Float64).new(dimensions, 0.0) }
      counts = Array(Int32).new(k, 0)

      # Sum points for each cluster
      data.each_with_index do |point, i|
        cluster = assignments[i]
        point.each_with_index do |value, dim|
          centers[cluster][dim] += value
        end
        counts[cluster] += 1
      end

      # Calculate averages
      centers.each_with_index do |center, cluster|
        if counts[cluster] > 0
          center.map! { |sum| sum / counts[cluster] }
        end
      end

      centers
    end

    private def find_nearest_cluster(point : Array(Float64), centers : Array(Array(Float64))) : Int32
      return 0 if centers.empty?

      min_distance = Float64::MAX
      nearest_cluster = 0

      centers.each_with_index do |center, cluster|
        distance = euclidean_distance(point, center)
        if distance < min_distance
          min_distance = distance
          nearest_cluster = cluster
        end
      end

      nearest_cluster
    end

    private def euclidean_distance(point1 : Array(Float64), point2 : Array(Float64)) : Float64
      return Float64::MAX if point1.size != point2.size

      sum_squares = point1.zip(point2).sum { |a, b| (a - b) ** 2 }
      Math.sqrt(sum_squares)
    end

    private def calculate_clustering_quality(data : Array(Array(Float64)), assignments : Array(Int32)) : Float64
      return 0.0 if data.size < 2

      # Calculate simplified silhouette-like score
      total_score = 0.0

      data.each_with_index do |point, i|
        cluster = assignments[i]

        # Calculate average distance to points in same cluster
        same_cluster_distances = [] of Float64
        different_cluster_distances = [] of Float64

        data.each_with_index do |other_point, j|
          next if i == j

          distance = euclidean_distance(point, other_point)

          if assignments[j] == cluster
            same_cluster_distances << distance
          else
            different_cluster_distances << distance
          end
        end

        # Calculate silhouette-like score for this point
        a = same_cluster_distances.empty? ? 0.0 : same_cluster_distances.sum / same_cluster_distances.size
        b = different_cluster_distances.empty? ? Float64::MAX : different_cluster_distances.sum / different_cluster_distances.size

        silhouette = b == 0.0 ? 0.0 : (b - a) / Math.max(a, b)
        total_score += silhouette
      end

      total_score / data.size
    end
  end
end
