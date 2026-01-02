# MOSES deme (subpopulation) management
# Implements deme expansion and local search within program neighborhoods

require "./types"
require "./representation"

module Moses
  # A deme represents a subpopulation exploring a specific region of the program space
  class Deme
    property exemplar : Candidate
    property population : Array(Candidate)
    property scoring_function : ScoringFunction
    property size : Int32
    property generation : Int32
    property best_score : CompositeScore?

    def initialize(@exemplar : Candidate, @scoring_function : ScoringFunction, @size : Int32 = 20)
      @population = Array(Candidate).new
      @generation = 0
      @best_score = nil
      expand_from_exemplar
    end

    # Expand the deme by generating variations of the exemplar
    def expand_from_exemplar
      @population.clear
      @population << @exemplar

      generator = Representation::ProgramMutator.new(0.3, 2) # Higher mutation rate for exploration

      # Generate variations
      (size - 1).times do
        variation = generate_variation(@exemplar.program)
        candidate = Candidate.new(variation, @generation)
        @population << candidate
      end
    end

    # Optimize the deme using local search
    def optimize(max_generations : Int32 = 10) : Array(Candidate)
      CogUtil::Logger.debug("Optimizing deme with exemplar: #{@exemplar.program}")

      max_generations.times do |gen|
        @generation = gen

        # Evaluate all candidates if not already evaluated
        @population.each do |candidate|
          unless candidate.scored?
            @scoring_function.score(candidate)
          end
        end

        # Update best score
        current_best = @population.max_by { |c| Moses.score_or_worst(c) }
        current_best_score = current_best.score

        if current_best_score && (@best_score.nil? || current_best_score > @best_score.not_nil!)
          @best_score = current_best_score
          CogUtil::Logger.debug("Deme best score improved: #{@best_score}")
        end

        # Selection and reproduction
        selected = select_parents
        offspring = generate_offspring(selected)

        # Replace population with offspring (plus elites)
        @population = (selected[0..2] + offspring)[0...size] # Keep top 3 + offspring
      end

      # Return best candidates
      @population.sort_by { |c| Moses.score_or_worst(c) }.reverse[0..4]
    end

    # Select parent candidates for reproduction
    private def select_parents : Array(Candidate)
      # Tournament selection
      selected = Array(Candidate).new
      tournament_size = Math.min(5, @population.size)

      4.times do # Select 4 parents
        tournament = @population.sample(tournament_size)
        winner = tournament.max_by { |c| Moses.score_or_worst(c) }
        selected << winner
      end

      selected
    end

    # Generate offspring from parent candidates
    private def generate_offspring(parents : Array(Candidate)) : Array(Candidate)
      offspring = Array(Candidate).new
      mutator = Representation::ProgramMutator.new(0.15, 2)
      crossover = Representation::ProgramCrossover.new

      # Generate offspring through mutation and crossover
      (size // 2).times do
        parent1 = parents.sample
        parent2 = parents.sample

        if Random.rand < 0.7 # Crossover probability
          child1_prog, child2_prog = crossover.crossover(parent1.program, parent2.program)
          offspring << Candidate.new(child1_prog, @generation + 1)
          offspring << Candidate.new(child2_prog, @generation + 1)
        else
          # Mutation only
          child1_prog = mutator.mutate(parent1.program)
          child2_prog = mutator.mutate(parent2.program)
          offspring << Candidate.new(child1_prog, @generation + 1)
          offspring << Candidate.new(child2_prog, @generation + 1)
        end
      end

      offspring
    end

    # Generate a single variation of a program
    private def generate_variation(program : String) : String
      mutator = Representation::ProgramMutator.new(0.2, 2)
      mutator.mutate(program)
    end

    # Get the best candidates from this deme
    def best_candidates(count : Int32 = 5) : Array(Candidate)
      @population.sort_by { |c| Moses.score_or_worst(c) }.reverse[0...count]
    end

    # Get statistics about this deme
    def statistics : Hash(String, Float64 | Int32)
      scores = @population.compact_map(&.score.try(&.penalized_score))

      {
        "size"        => @population.size,
        "generation"  => @generation,
        "mean_score"  => scores.empty? ? 0.0 : scores.sum / scores.size,
        "best_score"  => scores.empty? ? 0.0 : scores.max,
        "worst_score" => scores.empty? ? 0.0 : scores.min,
        "diversity"   => calculate_diversity,
      }
    end

    # Calculate program diversity in the deme
    private def calculate_diversity : Float64
      return 0.0 if @population.size < 2

      programs = @population.map(&.program).uniq
      programs.size.to_f / @population.size
    end
  end

  # Deme expander - manages the creation and expansion of demes
  class DemeExpander
    property scoring_function : ScoringFunction
    property deme_size : Int32

    def initialize(@scoring_function : ScoringFunction, @deme_size : Int32 = 20)
    end

    # Create a new deme from an exemplar
    def create_deme(exemplar : Candidate) : Deme
      deme = Deme.new(exemplar, @scoring_function, @deme_size)
      CogUtil::Logger.debug("Created deme with exemplar: #{exemplar.program}")
      deme
    end

    # Optimize a deme and return promising candidates
    def optimize_deme(deme : Deme, max_generations : Int32 = 10) : Array(Candidate)
      candidates = deme.optimize(max_generations)

      stats = deme.statistics
      CogUtil::Logger.info("Deme optimization complete - best score: #{stats["best_score"]}, diversity: #{stats["diversity"]}")

      candidates
    end
  end
end
