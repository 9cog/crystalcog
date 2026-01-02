# MOSES metapopulation management
# Manages the collection of best candidates and spawns new demes

require "./types"
require "./deme"
require "./representation"

module Moses
  # The metapopulation maintains the best candidates found across all demes
  # and is responsible for spawning new demes for exploration
  class MetaPopulation
    property candidates : Array(Candidate)
    property scoring_function : ScoringFunction
    property deme_expander : DemeExpander
    property max_size : Int32
    property generations : Int32
    property total_evals : Int32
    property best_score : CompositeScore?
    property stagnation_count : Int32

    def initialize(params : MosesParams, @scoring_function : ScoringFunction)
      @candidates = Array(Candidate).new
      @deme_expander = DemeExpander.new(@scoring_function, params.deme_size)
      @max_size = params.population_size
      @generations = 0
      @total_evals = 0
      @best_score = nil
      @stagnation_count = 0

      # Initialize with random candidates
      initialize_population(params)
    end

    # Convenience constructor for self.new in moses.cr
    def self.new(params : MosesParams)
      scoring_func = case params.problem_type
                     when ProblemType::BooleanClassification
                       BooleanTableScoring.new(params.training_data, params.target_data || [] of Float64)
                     when ProblemType::Regression
                       RegressionScoring.new(params.training_data, params.target_data || [] of Float64)
                     else
                       ClusteringScoring.new(params.training_data)
                     end

      new(params, scoring_func)
    end

    # Main evolutionary loop
    def run(scoring_func : ScoringFunction, max_evals : Int32) : Array(Candidate)
      @scoring_function = scoring_func

      CogUtil::Logger.info("Starting MOSES evolution with #{@candidates.size} initial candidates")

      while @total_evals < max_evals && should_continue?
        @generations += 1

        # Select exemplar for new deme
        exemplar = select_exemplar

        # Create and optimize deme
        deme = @deme_expander.create_deme(exemplar)
        promising_candidates = @deme_expander.optimize_deme(deme)

        # Update evaluation count
        @total_evals += @scoring_function.evaluations

        # Merge promising candidates into metapopulation
        merge_candidates(promising_candidates)

        # Update best score and stagnation tracking
        update_best_score

        # Log progress
        if @generations % 10 == 0
          log_progress
        end

        # Check termination criteria
        break if @stagnation_count > 20
      end

      CogUtil::Logger.info("MOSES evolution complete - #{@generations} generations, #{@total_evals} evaluations")
      best_candidates(10)
    end

    # Initialize population with random candidates
    private def initialize_population(params : MosesParams)
      generator = Representation::ProgramGenerator.new(
        params.problem_type,
        params.training_data.first?.try(&.size) || 2
      )

      @max_size.times do |i|
        program = generator.generate_random
        candidate = Candidate.new(program, 0)
        @scoring_function.score(candidate)
        @candidates << candidate
      end

      @total_evals = @scoring_function.evaluations
      CogUtil::Logger.info("Initialized metapopulation with #{@candidates.size} random candidates")
    end

    # Select an exemplar candidate for spawning a new deme
    private def select_exemplar : Candidate
      # Tournament selection with bias toward good but diverse candidates
      tournament_size = Math.min(10, @candidates.size)
      tournament = @candidates.sample(tournament_size)

      # Select best from tournament
      tournament.max_by { |c| Moses.score_or_worst(c) }
    end

    # Merge new candidates into the metapopulation
    private def merge_candidates(new_candidates : Array(Candidate))
      # Add new candidates
      @candidates.concat(new_candidates)

      # Remove duplicates (same program)
      unique_programs = Set(String).new
      @candidates = @candidates.select do |candidate|
        if unique_programs.includes?(candidate.program)
          false
        else
          unique_programs.add(candidate.program)
          true
        end
      end

      # Keep only the best candidates
      @candidates.sort_by! { |c| Moses.score_or_worst(c) }
      @candidates.reverse! # Best first
      @candidates = @candidates[0...@max_size] if @candidates.size > @max_size

      CogUtil::Logger.debug("Metapopulation size after merge: #{@candidates.size}")
    end

    # Update best score and stagnation tracking
    private def update_best_score
      current_best = @candidates.first?.try(&.score)

      if current_best && (@best_score.nil? || current_best > @best_score.not_nil!)
        @best_score = current_best
        @stagnation_count = 0
        CogUtil::Logger.info("New best score: #{@best_score}")
      else
        @stagnation_count += 1
      end
    end

    # Check if evolution should continue
    private def should_continue? : Bool
      return false if @candidates.empty?
      return false if @stagnation_count > 30
      true
    end

    # Log evolution progress
    private def log_progress
      best = @candidates.first?
      stats = calculate_statistics

      CogUtil::Logger.info("Generation #{@generations}: " +
                           "best=#{best.try(&.score.try(&.penalized_score))}, " +
                           "mean=#{stats["mean_score"]}, " +
                           "diversity=#{stats["diversity"]}, " +
                           "evals=#{@total_evals}")
    end

    # Calculate population statistics
    def calculate_statistics : Hash(String, Float64)
      return {"mean_score" => 0.0, "diversity" => 0.0} if @candidates.empty?

      scores = @candidates.compact_map(&.score.try(&.penalized_score))
      programs = @candidates.map(&.program).uniq

      {
        "mean_score"  => scores.empty? ? 0.0 : scores.sum / scores.size,
        "best_score"  => scores.empty? ? 0.0 : scores.max,
        "worst_score" => scores.empty? ? 0.0 : scores.min,
        "diversity"   => programs.size.to_f / @candidates.size,
      }
    end

    # Get the best candidates from the metapopulation
    def best_candidates(count : Int32 = 10) : Array(Candidate)
      @candidates[0...Math.min(count, @candidates.size)]
    end

    # Get the single best candidate
    def best_candidate : Candidate?
      @candidates.first?
    end

    # Get current population size
    def size : Int32
      @candidates.size
    end
  end
end
