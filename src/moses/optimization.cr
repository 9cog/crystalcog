# MOSES optimization algorithms
# Implements the core optimization strategies used in MOSES

require "./types"
require "./representation"

module Moses
  # Core optimization module containing various optimization strategies
  module Optimization
    # Hill climbing optimizer for local search
    class HillClimber
      property scoring_function : ScoringFunction
      property max_iterations : Int32
      property step_size : Float64

      def initialize(@scoring_function : ScoringFunction, @max_iterations : Int32 = 100, @step_size : Float64 = 0.1)
      end

      # Perform hill climbing optimization on a candidate
      def optimize(candidate : Candidate) : Candidate
        current = candidate
        mutator = Representation::ProgramMutator.new(@step_size, 2)

        @max_iterations.times do |iteration|
          # Generate neighbor
          neighbor_program = mutator.mutate(current.program)
          neighbor = Candidate.new(neighbor_program, current.generation + 1)

          # Evaluate neighbor
          @scoring_function.score(neighbor)

          # Accept if better
          if neighbor.score && current.score && neighbor.score.not_nil! > current.score.not_nil!
            current = neighbor
            CogUtil::Logger.debug("Hill climbing improvement at iteration #{iteration}: #{current.score}")
          end
        end

        current
      end
    end

    # Simulated annealing optimizer
    class SimulatedAnnealing
      property scoring_function : ScoringFunction
      property initial_temperature : Float64
      property cooling_rate : Float64
      property max_iterations : Int32

      def initialize(@scoring_function : ScoringFunction, @initial_temperature : Float64 = 100.0,
                     @cooling_rate : Float64 = 0.95, @max_iterations : Int32 = 1000)
      end

      # Perform simulated annealing optimization
      def optimize(candidate : Candidate) : Candidate
        current = candidate
        best = candidate
        temperature = @initial_temperature
        mutator = Representation::ProgramMutator.new(0.2, 2)

        @max_iterations.times do |iteration|
          # Generate neighbor
          neighbor_program = mutator.mutate(current.program)
          neighbor = Candidate.new(neighbor_program, current.generation + 1)

          # Evaluate neighbor
          @scoring_function.score(neighbor)

          # Calculate acceptance probability
          if accept_neighbor?(current, neighbor, temperature)
            current = neighbor

            # Update best if improved
            if best.score && neighbor.score && neighbor.score.not_nil! > best.score.not_nil!
              best = neighbor
              CogUtil::Logger.debug("Simulated annealing new best at iteration #{iteration}: #{best.score}")
            end
          end

          # Cool down
          temperature *= @cooling_rate
        end

        best
      end

      private def accept_neighbor?(current : Candidate, neighbor : Candidate, temperature : Float64) : Bool
        return true unless current.score && neighbor.score

        current_score = current.score.not_nil!.penalized_score
        neighbor_score = neighbor.score.not_nil!.penalized_score

        # Always accept if better
        return true if neighbor_score > current_score

        # Accept worse solutions with probability based on temperature
        if temperature > 0
          probability = Math.exp((neighbor_score - current_score) / temperature)
          Random.rand < probability
        else
          false
        end
      end
    end

    # Genetic algorithm optimizer
    class GeneticAlgorithm
      property scoring_function : ScoringFunction
      property population_size : Int32
      property mutation_rate : Float64
      property crossover_rate : Float64
      property elitism_count : Int32

      def initialize(@scoring_function : ScoringFunction, @population_size : Int32 = 50,
                     @mutation_rate : Float64 = 0.1, @crossover_rate : Float64 = 0.8, @elitism_count : Int32 = 2)
      end

      # Optimize a population using genetic algorithm
      def optimize(initial_candidates : Array(Candidate), generations : Int32 = 50) : Array(Candidate)
        population = initial_candidates.dup
        mutator = Representation::ProgramMutator.new(@mutation_rate, 2)
        crossover = Representation::ProgramCrossover.new

        # Ensure population is evaluated
        population.each { |candidate| @scoring_function.score(candidate) unless candidate.scored? }

        generations.times do |gen|
          # Selection
          parents = tournament_selection(population)

          # Create offspring
          offspring = Array(Candidate).new

          while offspring.size < population.size - @elitism_count
            parent1 = parents.sample
            parent2 = parents.sample

            if Random.rand < @crossover_rate
              # Crossover
              child1_prog, child2_prog = crossover.crossover(parent1.program, parent2.program)
              offspring << Candidate.new(child1_prog, gen + 1)
              offspring << Candidate.new(child2_prog, gen + 1) if offspring.size < population.size - @elitism_count
            else
              # Mutation only
              child_prog = mutator.mutate(parent1.program)
              offspring << Candidate.new(child_prog, gen + 1)
            end
          end

          # Evaluate offspring
          offspring.each { |candidate| @scoring_function.score(candidate) }

          # Combine with elites
          population.sort_by! { |c| Moses.score_or_worst(c) }
          population.reverse! # Best first
          elites = population[0...@elitism_count]

          population = (elites + offspring)[0...@population_size]

          if gen % 10 == 0
            best_score = population.first?.try(&.score.try(&.penalized_score))
            CogUtil::Logger.debug("GA generation #{gen}: best score = #{best_score}")
          end
        end

        population.sort_by { |c| Moses.score_or_worst(c) }.reverse
      end

      private def tournament_selection(population : Array(Candidate), tournament_size : Int32 = 3) : Array(Candidate)
        selected = Array(Candidate).new

        population.size.times do
          tournament = population.sample(Math.min(tournament_size, population.size))
          winner = tournament.max_by { |c| Moses.score_or_worst(c) }
          selected << winner
        end

        selected
      end
    end

    # Ensemble optimizer that combines multiple optimization strategies
    class EnsembleOptimizer
      property optimizers : Array(HillClimber | SimulatedAnnealing | GeneticAlgorithm)

      def initialize(@optimizers : Array(HillClimber | SimulatedAnnealing | GeneticAlgorithm))
      end

      # Apply multiple optimization strategies and return best results
      def optimize(candidates : Array(Candidate)) : Array(Candidate)
        all_results = Array(Candidate).new

        @optimizers.each_with_index do |optimizer, i|
          CogUtil::Logger.debug("Running optimizer #{i + 1}/#{@optimizers.size}")

          case optimizer
          when HillClimber, SimulatedAnnealing
            # Single candidate optimizers
            candidates.each do |candidate|
              result = optimizer.optimize(candidate)
              all_results << result
            end
          when GeneticAlgorithm
            # Population optimizer
            results = optimizer.optimize(candidates)
            all_results.concat(results)
          end
        end

        # Return best unique results
        unique_programs = Set(String).new
        unique_results = all_results.select do |candidate|
          if unique_programs.includes?(candidate.program)
            false
          else
            unique_programs.add(candidate.program)
            true
          end
        end

        unique_results.sort_by { |c| Moses.score_or_worst(c) }.reverse
      end
    end
  end
end
