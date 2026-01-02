# MOSES program representation
# Handles the representation and manipulation of evolved programs

require "./types"

module Moses
  # Program representation using simplified combo-like syntax
  # In full MOSES, this would be a complete combo tree implementation
  module Representation
    # Simple program generator for creating initial random programs
    class ProgramGenerator
      property problem_type : ProblemType
      property input_size : Int32
      property max_depth : Int32

      def initialize(@problem_type : ProblemType, @input_size : Int32, @max_depth : Int32 = 3)
      end

      # Generate a random program based on problem type
      def generate_random : String
        case problem_type
        when ProblemType::BooleanClassification
          generate_boolean_program
        when ProblemType::Regression
          generate_regression_program
        else
          generate_simple_program
        end
      end

      private def generate_boolean_program : String
        operators = ["and", "or", "not"]
        variables = (0...input_size).map { |i| "$#{i}" }

        # Simple random boolean expression
        if Random.rand < 0.3
          # Simple variable
          variables.sample
        elsif Random.rand < 0.6
          # Binary operation
          op = operators.sample
          if op == "not"
            "not #{variables.sample}"
          else
            "#{variables.sample} #{op} #{variables.sample}"
          end
        else
          # More complex expression
          "#{variables.sample} and (#{variables.sample} or #{variables.sample})"
        end
      end

      private def generate_regression_program : String
        operators = ["+", "-", "*", "/"]
        variables = (0...input_size).map { |i| "$#{i}" }
        constants = ["1.0", "2.0", "0.5", "10.0"]

        # Simple random arithmetic expression
        if Random.rand < 0.3
          # Simple variable or constant
          (variables + constants).sample
        elsif Random.rand < 0.7
          # Binary operation
          op = operators.sample
          left = (variables + constants).sample
          right = (variables + constants).sample
          "#{left} #{op} #{right}"
        else
          # More complex expression
          "#{variables.sample} + (#{variables.sample} * #{constants.sample})"
        end
      end

      private def generate_simple_program : String
        variables = (0...input_size).map { |i| "$#{i}" }
        variables.sample
      end
    end

    # Program mutator for evolutionary operations
    class ProgramMutator
      property mutation_rate : Float64
      property input_size : Int32

      def initialize(@mutation_rate : Float64 = 0.1, @input_size : Int32 = 2)
      end

      # Mutate a program string
      def mutate(program : String) : String
        return program if Random.rand > mutation_rate

        # Simple mutation strategies
        case Random.rand
        when 0.0..0.3
          mutate_variable(program)
        when 0.3..0.6
          mutate_operator(program)
        else
          mutate_structure(program)
        end
      end

      private def mutate_variable(program : String) : String
        variables = (0...input_size).map { |i| "$#{i}" }

        # Replace a random variable with another
        old_var = variables.sample
        new_var = variables.sample

        program.gsub(old_var, new_var)
      end

      private def mutate_operator(program : String) : String
        # Replace operators
        replacements = {
          "and" => "or",
          "or"  => "and",
          "+"   => "-",
          "-"   => "+",
          "*"   => "/",
          "/"   => "*",
        }

        replacements.each do |old_op, new_op|
          if program.includes?(old_op) && Random.rand < 0.5
            return program.gsub(old_op, new_op)
          end
        end

        program
      end

      private def mutate_structure(program : String) : String
        # Add or remove parentheses, or add/remove subexpressions
        if program.includes?("(") && Random.rand < 0.5
          # Remove some parentheses
          program.gsub("(", "").gsub(")", "")
        else
          # Add complexity
          variables = (0...input_size).map { |i| "$#{i}" }
          extra = variables.sample
          "#{program} and #{extra}"
        end
      end
    end

    # Program crossover for evolutionary operations
    class ProgramCrossover
      def initialize
      end

      # Perform crossover between two parent programs
      def crossover(parent1 : String, parent2 : String) : Tuple(String, String)
        # Simple string-based crossover for demonstration
        # In full MOSES, this would operate on combo trees

        if parent1.size < 3 || parent2.size < 3
          return {parent1, parent2}
        end

        # Random crossover points
        point1 = Random.rand(1..parent1.size - 1)
        point2 = Random.rand(1..parent2.size - 1)

        # Create offspring
        child1 = parent1[0...point1] + parent2[point2..]
        child2 = parent2[0...point2] + parent1[point1..]

        {child1, child2}
      end
    end

    # Program complexity calculator
    module Complexity
      # Calculate the complexity of a program
      def self.calculate(program : String) : Complexity
        # Simple complexity based on length and operators
        base = program.size
        operators = program.count(" and ") + program.count(" or ") +
                    program.count(" + ") + program.count(" - ") +
                    program.count(" * ") + program.count(" / ")
        parentheses = program.count("(") + program.count(")")

        base + operators * 2 + parentheses
      end
    end
  end
end
