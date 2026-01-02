require "../src/cogutil/cogutil"
require "../src/atomspace/atomspace_main"
require "benchmark"

CogUtil.initialize
AtomSpace.initialize

puts "AtomSpace Performance Benchmarks"
puts "================================="

Benchmark.ips do |bench|
  atomspace = AtomSpace::AtomSpace.new
  
  bench.report("create_concept_node") do
    atomspace.add_node(AtomSpace::AtomType::CONCEPT_NODE, "test_#{rand(10000)}")
  end
  
  # Pre-create some atoms for link tests
  dog = atomspace.add_node(AtomSpace::AtomType::CONCEPT_NODE, "dog")
  animal = atomspace.add_node(AtomSpace::AtomType::CONCEPT_NODE, "animal")
  
  bench.report("create_inheritance_link") do
    atomspace.add_link(AtomSpace::AtomType::INHERITANCE_LINK, [dog, animal])
  end
  
  bench.report("atomspace_lookup") do
    atomspace.contains?(dog)
  end
end
