# AttentionBank - Core component for managing attention allocation
# Manages STI/LTI funds, attentional focus, and attention allocation

require "./attention"

module Attention
  # Manages the economic attention allocation system
  class AttentionBank
    # Current attention funds
    getter sti_funds : Int16
    getter lti_funds : Int16

    # Attentional focus - atoms with highest STI
    getter attentional_focus : Array(AtomSpace::Handle)

    # Target and current focus parameters
    getter af_max_size : Int32
    getter af_min_size : Int32

    # Fund buffers for wage calculations
    getter sti_wage : Int16
    getter lti_wage : Int16

    # Associated atomspace
    getter atomspace : AtomSpace::AtomSpace

    def initialize(@atomspace : AtomSpace::AtomSpace,
                   @af_max_size = ECANParams::AF_MAX_SIZE,
                   @af_min_size = ECANParams::AF_MIN_SIZE)
      @sti_funds = ECANParams::TARGET_STI_FUNDS
      @lti_funds = ECANParams::TARGET_LTI_FUNDS
      @attentional_focus = Array(AtomSpace::Handle).new
      @sti_wage = 1_i16
      @lti_wage = 1_i16

      CogUtil::Logger.info("AttentionBank", "Initialized with STI funds: #{@sti_funds}, LTI funds: #{@lti_funds}")
    end

    # Set attention value for an atom
    def set_attention_value(handle : AtomSpace::Handle, av : AtomSpace::AttentionValue)
      atom = @atomspace.get_atom(handle)
      return false if atom.nil?

      old_av = atom.attention_value
      atom.attention_value = av

      # Update funds - subtract new values, add old values
      if old_av
        @sti_funds += old_av.sti - av.sti
        @lti_funds += old_av.lti - av.lti
      else
        @sti_funds -= av.sti
        @lti_funds -= av.lti
      end

      # Update attentional focus
      update_attentional_focus(handle, old_av, av)

      true
    end

    # Get attention value for an atom
    def get_attention_value(handle : AtomSpace::Handle) : AtomSpace::AttentionValue?
      atom = @atomspace.get_atom(handle)
      atom.try &.attention_value
    end

    # Stimulate an atom by increasing its STI
    def stimulate(handle : AtomSpace::Handle, stimulus : Int16 = 10_i16)
      current_av = get_attention_value(handle)

      if current_av.nil?
        new_av = AtomSpace::AttentionValue.new(stimulus, 0_i16, false)
      else
        new_sti = Math.min(ECANParams::MAX_STI, current_av.sti + stimulus)
        new_av = AtomSpace::AttentionValue.new(new_sti, current_av.lti, current_av.vlti)
      end

      set_attention_value(handle, new_av)
    end

    # Check if atom is in attentional focus
    def in_attentional_focus?(handle : AtomSpace::Handle) : Bool
      @attentional_focus.includes?(handle)
    end

    # Get minimum STI for attentional focus
    def get_af_min_sti : Int16
      return ECANParams::MIN_STI if @attentional_focus.empty?

      min_sti = ECANParams::MAX_STI
      @attentional_focus.each do |h|
        av = get_attention_value(h)
        if av
          min_sti = Math.min(min_sti, av.sti)
        end
      end
      min_sti
    end

    # Get maximum STI in attentional focus
    def get_af_max_sti : Int16
      return ECANParams::MIN_STI if @attentional_focus.empty?

      max_sti = ECANParams::MIN_STI
      @attentional_focus.each do |h|
        av = get_attention_value(h)
        if av
          max_sti = Math.max(max_sti, av.sti)
        end
      end
      max_sti
    end

    # Update attentional focus when atom attention changes
    private def update_attentional_focus(handle : AtomSpace::Handle,
                                         old_av : AtomSpace::AttentionValue?,
                                         new_av : AtomSpace::AttentionValue)
      # Remove from AF if it was there
      @attentional_focus.delete(handle)

      # Check if should be added to AF
      if @attentional_focus.size < @af_max_size
        # Always add if AF not full
        @attentional_focus << handle
      else
        # Only add if STI is higher than minimum in AF
        min_sti = get_af_min_sti
        if new_av.sti > min_sti
          # Remove atom with minimum STI
          min_handle = find_min_sti_handle
          @attentional_focus.delete(min_handle) if min_handle
          @attentional_focus << handle
        end
      end

      # Sort AF by STI (highest first)
      @attentional_focus.sort! do |a, b|
        av_a = get_attention_value(a)
        av_b = get_attention_value(b)

        sti_a = av_a ? av_a.sti : ECANParams::MIN_STI
        sti_b = av_b ? av_b.sti : ECANParams::MIN_STI

        sti_b <=> sti_a # Descending order
      end

      # Trim to max size if needed
      if @attentional_focus.size > @af_max_size
        @attentional_focus = @attentional_focus[0...@af_max_size]
      end
    end

    # Find handle with minimum STI in attentional focus
    private def find_min_sti_handle : AtomSpace::Handle?
      return nil if @attentional_focus.empty?

      min_sti = ECANParams::MAX_STI
      min_handle : AtomSpace::Handle? = nil

      @attentional_focus.each do |h|
        av = get_attention_value(h)
        if av && av.sti < min_sti
          min_sti = av.sti
          min_handle = h
        end
      end

      min_handle
    end

    # Calculate STI wage based on current funds
    def calculate_sti_wage : Int16
      atomspace_size = @atomspace.size
      if @sti_funds > 0 && atomspace_size > 0
        Math.max(1_i16, (@sti_funds // atomspace_size).to_i16)
      else
        0_i16
      end
    end

    # Calculate LTI wage based on current funds
    def calculate_lti_wage : Int16
      atomspace_size = @atomspace.size
      if @lti_funds > 0 && atomspace_size > 0
        Math.max(1_i16, (@lti_funds // atomspace_size).to_i16)
      else
        0_i16
      end
    end

    # Get statistics about current attention allocation
    def get_statistics
      {
        "sti_funds"      => @sti_funds.to_i32,
        "lti_funds"      => @lti_funds.to_i32,
        "af_size"        => @attentional_focus.size.to_i32,
        "af_max_size"    => @af_max_size.to_i32,
        "af_min_sti"     => get_af_min_sti.to_i32,
        "af_max_sti"     => get_af_max_sti.to_i32,
        "atomspace_size" => @atomspace.size.to_i32,
        "sti_wage"       => calculate_sti_wage.to_i32,
        "lti_wage"       => calculate_lti_wage.to_i32,
      }
    end

    # Add funds to the bank (used by rent collection)
    def add_sti_funds(amount : Int16)
      @sti_funds += amount
    end

    def add_lti_funds(amount : Int16)
      @lti_funds += amount
    end

    # Subtract funds from the bank (used by stimulation/boosting)
    def subtract_sti_funds(amount : Int16)
      @sti_funds = Math.max(ECANParams::MIN_STI, @sti_funds - amount)
    end

    def subtract_lti_funds(amount : Int16)
      @lti_funds = Math.max(ECANParams::MIN_STI, @lti_funds - amount)
    end

    def to_s(io : IO) : Nil
      stats = get_statistics
      io << "AttentionBank[STI Funds:#{stats["sti_funds"]}, LTI Funds:#{stats["lti_funds"]}, AF Size:#{stats["af_size"]}/#{stats["af_max_size"]}]"
    end
  end
end
