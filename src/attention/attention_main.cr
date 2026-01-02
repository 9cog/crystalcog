# Main attention module that provides unified access to all attention mechanisms

require "./attention"
require "./attention_bank"
require "./diffusion"
require "./rent_collector"
require "./allocation_engine"

# Main attention module
module Attention
  # Module-level convenience functions

  # Create a new allocation engine
  def self.create_engine(atomspace : AtomSpace::AtomSpace) : AllocationEngine
    AllocationEngine.new(atomspace)
  end

  # Quick attention allocation on an atomspace
  def self.allocate_attention(atomspace : AtomSpace::AtomSpace,
                              cycles : Int32 = 1,
                              goals : Hash(Goal, Float64)? = nil) : Hash(String, Float64)
    engine = create_engine(atomspace)

    if goals
      engine.set_goals(goals)
    end

    engine.allocate_attention(cycles)
  end

  # Focus attention on specific atoms
  def self.focus_on(atomspace : AtomSpace::AtomSpace,
                    handles : Array(AtomSpace::Handle),
                    boost : Int16 = 50_i16)
    engine = create_engine(atomspace)
    engine.focus_attention(handles, boost)
  end

  # Get attention statistics for an atomspace
  def self.get_statistics(atomspace : AtomSpace::AtomSpace) : Hash(String, Float64)
    engine = create_engine(atomspace)
    engine.get_allocation_statistics
  end

  # Set attention value for an atom (convenience function)
  def self.set_attention(atomspace : AtomSpace::AtomSpace,
                         handle : AtomSpace::Handle,
                         sti : Int16,
                         lti : Int16 = 0_i16,
                         vlti : Bool = false)
    bank = AttentionBank.new(atomspace)
    av = AtomSpace::AttentionValue.new(sti, lti, vlti)
    bank.set_attention_value(handle, av)
  end

  # Get attention value for an atom (convenience function)
  def self.get_attention(atomspace : AtomSpace::AtomSpace,
                         handle : AtomSpace::Handle) : AtomSpace::AttentionValue?
    bank = AttentionBank.new(atomspace)
    bank.get_attention_value(handle)
  end

  # Stimulate an atom (convenience function)
  def self.stimulate(atomspace : AtomSpace::AtomSpace,
                     handle : AtomSpace::Handle,
                     amount : Int16 = 10_i16)
    bank = AttentionBank.new(atomspace)
    bank.stimulate(handle, amount)
  end
end
