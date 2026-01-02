# Rent collection mechanisms for attention economy
# Implements economic constraints on attention allocation

require "./attention"
require "./attention_bank"

module Attention
  # Manages rent collection to maintain attention economy
  class RentCollector
    getter bank : AttentionBank
    getter rent_rate : Float64
    getter collection_threshold : Int16

    def initialize(@bank : AttentionBank, @rent_rate = 0.01, @collection_threshold = 0_i16)
    end

    # Collect rent from all atoms with STI above threshold
    def collect_rent : Int16
      total_collected = 0_i16
      atoms_processed = 0_i32

      CogUtil::Logger.info("RentCollector", "Starting rent collection (rate: #{@rent_rate})")

      @bank.atomspace.get_all_atoms.each do |atom|
        av = @bank.get_attention_value(atom.handle)
        next unless av && av.sti > @collection_threshold

        # Calculate rent for this atom
        rent = calculate_rent(av.sti)
        next if rent <= 0

        # Collect rent by reducing STI
        new_sti = Math.max(ECANParams::MIN_STI, av.sti - rent)
        new_av = AtomSpace::AttentionValue.new(new_sti, av.lti, av.vlti)

        if @bank.set_attention_value(atom.handle, new_av)
          total_collected += rent
          atoms_processed += 1
        end
      end

      CogUtil::Logger.info("RentCollector", "Collected #{total_collected} STI from #{atoms_processed} atoms")

      # Add collected rent back to bank funds
      @bank.add_sti_funds(total_collected)

      total_collected
    end

    # Tournament-based rent collection (more sophisticated)
    def tournament_rent_collection : Int16
      total_collected = 0_i16

      CogUtil::Logger.info("RentCollector", "Starting tournament rent collection")

      # Create tournaments for atoms with high STI
      rentable_atoms = get_rentable_atoms

      while rentable_atoms.size >= ECANParams::RENT_TOURNAMENT_SIZE
        # Select tournament participants
        tournament = tournament_selection(rentable_atoms, ECANParams::RENT_TOURNAMENT_SIZE)

        # Collect rent from tournament participants
        tournament.each do |handle|
          av = @bank.get_attention_value(handle)
          next unless av

          rent = calculate_tournament_rent(av.sti, tournament.size)
          next if rent <= 0

          new_sti = Math.max(ECANParams::MIN_STI, av.sti - rent)
          new_av = AtomSpace::AttentionValue.new(new_sti, av.lti, av.vlti)

          if @bank.set_attention_value(handle, new_av)
            total_collected += rent
          end
        end

        # Remove processed atoms from candidates
        tournament.each { |h| rentable_atoms.delete(h) }
      end

      CogUtil::Logger.info("RentCollector", "Tournament collected #{total_collected} STI")

      # Add to bank funds
      @bank.add_sti_funds(total_collected)

      total_collected
    end

    # Collect rent specifically from attentional focus
    def af_rent_collection : Int16
      return 0_i16 if @bank.attentional_focus.empty?

      total_collected = 0_i16

      CogUtil::Logger.info("RentCollector", "Collecting rent from attentional focus")

      @bank.attentional_focus.each do |handle|
        av = @bank.get_attention_value(handle)
        next unless av && av.sti > 10 # Don't tax low STI atoms in AF

        # Higher rent rate for AF atoms (they're using premium attention)
        af_rent = calculate_rent(av.sti, @rent_rate * 2.0)
        next if af_rent <= 0

        new_sti = Math.max(ECANParams::MIN_STI, av.sti - af_rent)
        new_av = AtomSpace::AttentionValue.new(new_sti, av.lti, av.vlti)

        if @bank.set_attention_value(handle, new_av)
          total_collected += af_rent
        end
      end

      CogUtil::Logger.info("RentCollector", "AF rent collection: #{total_collected} STI")

      @bank.add_sti_funds(total_collected)
      total_collected
    end

    # Adaptive rent collection based on fund levels
    def adaptive_rent_collection : Int16
      # Adjust rent rate based on current fund levels
      fund_ratio = @bank.sti_funds.to_f64 / ECANParams::TARGET_STI_FUNDS.to_f64

      adaptive_rate = case fund_ratio
                      when .< 0.5
                        @rent_rate * 0.5 # Reduce rent when funds are low
                      when .> 1.5
                        @rent_rate * 2.0 # Increase rent when funds are high
                      else
                        @rent_rate
                      end

      CogUtil::Logger.info("RentCollector", "Adaptive rent rate: #{adaptive_rate} (fund ratio: #{fund_ratio})")

      # Temporarily change rate
      old_rate = @rent_rate
      @rent_rate = adaptive_rate

      collected = collect_rent

      # Restore original rate
      @rent_rate = old_rate

      collected
    end

    # Calculate rent for an atom based on its STI
    private def calculate_rent(sti : Int16, rate : Float64 = @rent_rate) : Int16
      return 0_i16 if sti <= @collection_threshold

      # Progressive taxation - higher STI atoms pay more
      base_rent = (sti.to_f64 * rate).round.to_i16

      # Apply progressive scaling
      if sti > 100
        progressive_bonus = ((sti - 100).to_f64 * rate * 0.5).round.to_i16
        base_rent += progressive_bonus
      end

      Math.max(0_i16, Math.min(sti // 2, base_rent)) # Never take more than half
    end

    # Calculate tournament-based rent
    private def calculate_tournament_rent(sti : Int16, tournament_size : Int32) : Int16
      base_rent = calculate_rent(sti)

      # Scale by tournament size - larger tournaments pay more
      tournament_multiplier = 1.0 + (tournament_size.to_f64 * 0.1)
      (base_rent.to_f64 * tournament_multiplier).round.to_i16
    end

    # Get atoms that can pay rent
    private def get_rentable_atoms : Array(AtomSpace::Handle)
      rentable = Array(AtomSpace::Handle).new

      @bank.atomspace.get_all_atoms.each do |atom|
        av = @bank.get_attention_value(atom.handle)
        if av && av.sti > @collection_threshold
          rentable << atom.handle
        end
      end

      # Sort by STI (highest first)
      rentable.sort! do |a, b|
        av_a = @bank.get_attention_value(a)
        av_b = @bank.get_attention_value(b)

        sti_a = av_a ? av_a.sti : ECANParams::MIN_STI
        sti_b = av_b ? av_b.sti : ECANParams::MIN_STI

        sti_b <=> sti_a
      end

      rentable
    end

    # Tournament selection for rent collection
    private def tournament_selection(candidates : Array(AtomSpace::Handle), size : Int32) : Array(AtomSpace::Handle)
      return candidates if candidates.size <= size

      # Take top STI atoms for tournament
      candidates[0...size]
    end

    # LTI-based rent adjustment
    def lti_rent_adjustment
      CogUtil::Logger.info("RentCollector", "Adjusting rent based on LTI values")

      adjustments = 0_i32

      @bank.atomspace.get_all_atoms.each do |atom|
        av = @bank.get_attention_value(atom.handle)
        next unless av && av.lti > 0

        # Atoms with high LTI get STI bonus (reducing effective rent)
        if av.lti > 50
          lti_bonus = Math.min(10_i16, av.lti // 10)
          new_sti = Math.min(ECANParams::MAX_STI, av.sti + lti_bonus)

          if new_sti != av.sti
            new_av = AtomSpace::AttentionValue.new(new_sti, av.lti, av.vlti)
            if @bank.set_attention_value(atom.handle, new_av)
              adjustments += 1
              @bank.subtract_sti_funds(lti_bonus) # Deduct from funds
            end
          end
        end
      end

      CogUtil::Logger.info("RentCollector", "Applied LTI adjustments to #{adjustments} atoms")
    end

    # Get rent collection statistics
    def get_statistics : Hash(String, Int32 | Float64)
      total_sti = 0_i32
      rentable_atoms = 0_i32
      af_atoms = 0_i32

      @bank.atomspace.get_all_atoms.each do |atom|
        av = @bank.get_attention_value(atom.handle)
        next unless av

        total_sti += av.sti
        if av.sti > @collection_threshold
          rentable_atoms += 1
        end
        if @bank.in_attentional_focus?(atom.handle)
          af_atoms += 1
        end
      end

      {
        "total_sti"              => total_sti,
        "rentable_atoms"         => rentable_atoms,
        "af_atoms"               => af_atoms,
        "rent_rate"              => @rent_rate,
        "collection_threshold"   => @collection_threshold.to_i32,
        "average_rent_potential" => rentable_atoms > 0 ? (total_sti.to_f64 * @rent_rate) : 0.0,
      }
    end
  end
end
