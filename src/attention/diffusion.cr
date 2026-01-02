# Attention diffusion algorithms for spreading attention between related atoms
# Implements both neighbor-based and Hebbian diffusion

require "./attention"
require "./attention_bank"

module Attention
  # Manages spreading of attention between atoms
  class AttentionDiffusion
    getter bank : AttentionBank

    def initialize(@bank : AttentionBank)
    end

    # Perform neighbor-based importance diffusion
    # Spreads attention from high-STI atoms to their neighbors
    def neighbor_diffusion(max_iterations : Int32 = 3)
      CogUtil::Logger.info("AttentionDiffusion", "Starting neighbor diffusion (max #{max_iterations} iterations)")

      iterations = 0
      while iterations < max_iterations
        diffused_any = false

        # Get atoms in attentional focus (sources of diffusion)
        @bank.attentional_focus.each do |source_handle|
          source_av = @bank.get_attention_value(source_handle)
          next unless source_av && source_av.sti > 0

          # Get neighbors (incoming and outgoing atoms)
          neighbors = get_neighbors(source_handle)
          next if neighbors.empty?

          # Calculate diffusion amount
          max_spread = (source_av.sti.to_f64 * ECANParams::MAX_SPREAD_PERCENTAGE).round.to_i16
          next if max_spread <= 0

          # Spread to neighbors using tournament selection
          selected_neighbors = tournament_selection(neighbors, ECANParams::DIFFUSION_TOURNAMENT_SIZE)

          if spread_attention(source_handle, selected_neighbors, max_spread)
            diffused_any = true
          end
        end

        # Stop if no diffusion occurred
        break unless diffused_any
        iterations += 1
      end

      CogUtil::Logger.info("AttentionDiffusion", "Completed #{iterations} diffusion iterations")
    end

    # Perform Hebbian learning-based diffusion
    # Spreads attention based on co-activation patterns
    def hebbian_diffusion(max_iterations : Int32 = 2)
      CogUtil::Logger.info("AttentionDiffusion", "Starting Hebbian diffusion")

      iterations = 0
      while iterations < max_iterations
        diffused_any = false

        # Find co-activated atom pairs
        coactivated_pairs = find_coactivated_pairs

        coactivated_pairs.each do |pair|
          handle1, handle2 = pair

          av1 = @bank.get_attention_value(handle1)
          av2 = @bank.get_attention_value(handle2)

          next unless av1 && av2

          # Transfer attention from higher to lower STI atom
          if av1.sti > av2.sti && av1.sti > 10
            transfer_amount = Math.min(5_i16, av1.sti // 4)
            transfer_hebbian_attention(handle1, handle2, transfer_amount)
            diffused_any = true
          elsif av2.sti > av1.sti && av2.sti > 10
            transfer_amount = Math.min(5_i16, av2.sti // 4)
            transfer_hebbian_attention(handle2, handle1, transfer_amount)
            diffused_any = true
          end
        end

        break unless diffused_any
        iterations += 1
      end

      CogUtil::Logger.info("AttentionDiffusion", "Completed #{iterations} Hebbian iterations")
    end

    # Get neighboring atoms (atoms in incoming/outgoing sets)
    private def get_neighbors(handle : AtomSpace::Handle) : Array(AtomSpace::Handle)
      neighbors = Array(AtomSpace::Handle).new
      atom = @bank.atomspace.get_atom(handle)

      return neighbors unless atom

      # For links, add all atoms in outgoing set
      if atom.is_a?(AtomSpace::Link)
        atom.outgoing.each { |out_atom| neighbors << out_atom.handle }
      end

      # Add atoms that reference this atom in their outgoing sets
      @bank.atomspace.get_all_atoms.each do |other_atom|
        if other_atom.is_a?(AtomSpace::Link) && other_atom.outgoing.any?(&.handle.==(handle))
          neighbors << other_atom.handle
        end
      end

      neighbors.uniq
    end

    # Tournament selection for choosing diffusion targets
    private def tournament_selection(candidates : Array(AtomSpace::Handle), tournament_size : Int32) : Array(AtomSpace::Handle)
      return candidates if candidates.size <= tournament_size

      selected = Array(AtomSpace::Handle).new
      tournament_size.times do
        # Pick random candidate
        candidate = candidates.sample
        if candidate && !selected.includes?(candidate)
          selected << candidate
        end
      end

      selected
    end

    # Spread attention from source to targets
    private def spread_attention(source : AtomSpace::Handle,
                                 targets : Array(AtomSpace::Handle),
                                 total_amount : Int16) : Bool
      return false if targets.empty? || total_amount <= 0

      source_av = @bank.get_attention_value(source)
      return false unless source_av

      # Amount to give each target
      per_target = total_amount // targets.size
      return false if per_target <= 0

      # Reduce source STI
      new_source_sti = Math.max(ECANParams::MIN_STI, source_av.sti - total_amount)
      new_source_av = AtomSpace::AttentionValue.new(new_source_sti, source_av.lti, source_av.vlti)
      @bank.set_attention_value(source, new_source_av)

      # Increase target STIs
      targets.each do |target|
        target_av = @bank.get_attention_value(target)

        if target_av
          new_target_sti = Math.min(ECANParams::MAX_STI, target_av.sti + per_target)
          new_target_av = AtomSpace::AttentionValue.new(new_target_sti, target_av.lti, target_av.vlti)
        else
          new_target_av = AtomSpace::AttentionValue.new(per_target, 0_i16, false)
        end

        @bank.set_attention_value(target, new_target_av)
      end

      true
    end

    # Find pairs of atoms that are co-activated (high STI)
    private def find_coactivated_pairs : Array(Tuple(AtomSpace::Handle, AtomSpace::Handle))
      pairs = Array(Tuple(AtomSpace::Handle, AtomSpace::Handle)).new

      # Look for atoms with high STI that are connected
      high_sti_atoms = @bank.attentional_focus.select do |handle|
        av = @bank.get_attention_value(handle)
        av && av.sti > 50
      end

      # Find connected pairs
      high_sti_atoms.each_with_index do |handle1, i|
        neighbors = get_neighbors(handle1)

        high_sti_atoms[(i + 1)..].each do |handle2|
          if neighbors.includes?(handle2)
            pairs << {handle1, handle2}
          end
        end
      end

      pairs
    end

    # Transfer attention via Hebbian learning
    private def transfer_hebbian_attention(from : AtomSpace::Handle,
                                           to : AtomSpace::Handle,
                                           amount : Int16)
      from_av = @bank.get_attention_value(from)
      to_av = @bank.get_attention_value(to)

      return unless from_av

      # Reduce from STI
      new_from_sti = Math.max(ECANParams::MIN_STI, from_av.sti - amount)
      new_from_av = AtomSpace::AttentionValue.new(new_from_sti, from_av.lti, from_av.vlti)
      @bank.set_attention_value(from, new_from_av)

      # Increase to STI
      if to_av
        new_to_sti = Math.min(ECANParams::MAX_STI, to_av.sti + amount)
        new_to_av = AtomSpace::AttentionValue.new(new_to_sti, to_av.lti, to_av.vlti)
      else
        new_to_av = AtomSpace::AttentionValue.new(amount, 0_i16, false)
      end

      @bank.set_attention_value(to, new_to_av)
    end

    # Get diffusion statistics
    def get_statistics : Hash(String, Int32 | Float64)
      total_sti = 0_i32
      atoms_with_attention = 0_i32

      @bank.atomspace.get_all_atoms.each do |atom|
        av = @bank.get_attention_value(atom.handle)
        if av && av.sti > 0
          total_sti += av.sti
          atoms_with_attention += 1
        end
      end

      {
        "total_sti"            => total_sti,
        "atoms_with_attention" => atoms_with_attention,
        "average_sti"          => atoms_with_attention > 0 ? (total_sti.to_f64 / atoms_with_attention) : 0.0,
        "af_coverage"          => (@bank.attentional_focus.size.to_f64 / @bank.atomspace.size) * 100.0,
      }
    end
  end
end
