require "spec"
require "../../src/attention/attention_main"

describe "Attention System Core Features" do
  it "initializes attention system correctly" do
    Attention.initialize
    Attention::VERSION.should eq("0.1.0")
  end

  it "creates attention engines" do
    atomspace = AtomSpace::AtomSpace.new
    engine = Attention.create_engine(atomspace)
    engine.should be_a(Attention::AllocationEngine)
  end

  it "manages attention values" do
    atomspace = AtomSpace::AtomSpace.new
    dog = atomspace.add_concept_node("dog")

    # Set attention
    Attention.set_attention(atomspace, dog.handle, 100_i16, 50_i16, true)

    # Get attention
    av = Attention.get_attention(atomspace, dog.handle)
    av.should_not be_nil
    av.not_nil!.sti.should eq(100)
    av.not_nil!.lti.should eq(50)
    av.not_nil!.vlti.should be_true
  end

  it "performs stimulation correctly" do
    atomspace = AtomSpace::AtomSpace.new
    dog = atomspace.add_concept_node("dog")

    Attention.stimulate(atomspace, dog.handle, 75_i16)

    av = Attention.get_attention(atomspace, dog.handle)
    av.should_not be_nil
    av.not_nil!.sti.should eq(75)
  end

  it "runs basic attention allocation" do
    atomspace = AtomSpace::AtomSpace.new

    # Create test atoms
    dog = atomspace.add_concept_node("dog")
    mammal = atomspace.add_concept_node("mammal")
    link = atomspace.add_inheritance_link(dog, mammal)

    # Give some initial attention
    Attention.stimulate(atomspace, dog.handle, 100_i16)

    # Run allocation
    results = Attention.allocate_attention(atomspace, 1)

    results.class.should eq(Hash(String, Float64))
    results.has_key?("bank_sti_funds").should be_true
    # Note: funds might increase due to rent collection, so just check it's reasonable
    results["bank_sti_funds"].should be >= 9000.0
    results["bank_sti_funds"].should be <= 11000.0
  end

  it "calculates priority factors correctly" do
    Attention::Priority::Critical.boost_factor.should eq(1.5)
    Attention::Priority::Medium.boost_factor.should eq(1.0)
    Attention::Priority::Minimal.boost_factor.should eq(0.6)
  end

  it "calculates goal factors correctly" do
    Attention::Goal::Reasoning.boost_factor.should eq(0.9)
    Attention::Goal::Learning.boost_factor.should eq(0.7)
    Attention::Goal::Processing.boost_factor.should eq(0.85)
  end

  it "manages attentional focus" do
    atomspace = AtomSpace::AtomSpace.new
    engine = Attention.create_engine(atomspace)

    dog = atomspace.add_concept_node("dog")
    cat = atomspace.add_concept_node("cat")

    # Initially empty AF
    engine.bank.attentional_focus.should be_empty

    # Stimulate atoms
    engine.bank.stimulate(dog.handle, 100_i16)
    engine.bank.stimulate(cat.handle, 150_i16)

    # Should now be in AF, sorted by STI
    engine.bank.attentional_focus.size.should eq(2)
    engine.bank.in_attentional_focus?(dog.handle).should be_true
    engine.bank.in_attentional_focus?(cat.handle).should be_true

    # Cat should be first (higher STI)
    first_handle = engine.bank.attentional_focus.first
    first_av = engine.bank.get_attention_value(first_handle)
    first_av.not_nil!.sti.should eq(150)
  end

  it "performs rent collection" do
    atomspace = AtomSpace::AtomSpace.new
    engine = Attention.create_engine(atomspace)

    dog = atomspace.add_concept_node("dog")
    engine.bank.stimulate(dog.handle, 100_i16)

    initial_funds = engine.bank.sti_funds
    initial_sti = engine.bank.get_attention_value(dog.handle).not_nil!.sti

    # Collect rent
    rent_collected = engine.rent_collector.collect_rent

    # Should have collected some rent
    rent_collected.should be > 0

    # Funds should increase, dog STI should decrease
    engine.bank.sti_funds.should be > initial_funds
    final_sti = engine.bank.get_attention_value(dog.handle).not_nil!.sti
    final_sti.should be < initial_sti
  end

  it "provides comprehensive statistics" do
    atomspace = AtomSpace::AtomSpace.new
    stats = Attention.get_statistics(atomspace)

    stats.class.should eq(Hash(String, Float64))
    stats.has_key?("bank_sti_funds").should be_true
    stats.has_key?("bank_af_size").should be_true
    stats.has_key?("active_goals").should be_true

    # Should have reasonable default values
    stats["bank_sti_funds"].should eq(10000.0)
    stats["active_goals"].should eq(4.0) # Default goals
  end
end
