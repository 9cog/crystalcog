#!/usr/bin/env crystal

# Distributed AtomSpace Clustering Demonstration
# This script demonstrates the basic functionality of the distributed
# AtomSpace clustering and synchronization system.

require "../src/atomspace/atomspace_module"

# Example 1: Basic cluster setup and single-node operations
def demo_basic_cluster
  puts "=== Demo 1: Basic Cluster Setup ==="
  
  # Create a local AtomSpace
  atomspace = AtomSpace.create_atomspace
  
  # Create a distributed cluster
  cluster = AtomSpace.create_distributed_cluster(
    cluster_id: "demo_cluster",
    atomspace: atomspace,
    host: "localhost",
    port: 25000
  )
  
  puts "Created cluster: #{cluster.cluster_id} with node: #{cluster.node_id}"
  
  # Start the cluster
  cluster.start
  puts "Cluster started on #{cluster.local_node.host}:#{cluster.local_node.port}"
  
  # Add some atoms through the cluster interface
  dog = cluster.add_atom(AtomSpace::ConceptNode.new("dog"))
  animal = cluster.add_atom(AtomSpace::ConceptNode.new("animal"))
  inheritance = cluster.add_atom(AtomSpace::InheritanceLink.new(dog, animal))
  
  puts "Added atoms: #{atomspace.size} total"
  
  # Show cluster statistics
  stats = cluster.cluster_stats
  puts "Cluster stats:"
  puts "  Total nodes: #{stats["total_nodes"]}"
  puts "  Active nodes: #{stats["active_nodes"]}"
  puts "  Local atoms: #{stats["local_atomspace_size"]}"
  puts "  Pending sync ops: #{stats["pending_sync_operations"]}"
  
  # Stop the cluster
  cluster.stop
  puts "Cluster stopped"
  puts
end

# Example 2: Distributed storage with different strategies
def demo_distributed_storage
  puts "=== Demo 2: Distributed Storage Strategies ==="
  
  # Create cluster
  atomspace = AtomSpace.create_atomspace
  cluster = AtomSpace.create_distributed_cluster("storage_demo", atomspace)
  cluster.start
  
  # Create distributed storage with hash-based partitioning
  storage = AtomSpace.create_distributed_storage(
    name: "demo_storage",
    cluster: cluster,
    local_storage_backend: "file",
    storage_path: "/tmp/demo_distributed_storage",
    partition_strategy: AtomSpace::PartitionStrategy::HashBased,
    replication_strategy: AtomSpace::ReplicationStrategy::PrimaryBackup,
    replication_factor: 2
  )
  
  storage.open
  puts "Opened distributed storage with #{storage.partition_strategy} partitioning"
  
  # Store some test data
  concepts = [
    AtomSpace::ConceptNode.new("cat"),
    AtomSpace::ConceptNode.new("mammal"),
    AtomSpace::ConceptNode.new("pet"),
    AtomSpace::ConceptNode.new("fluffy")
  ]
  
  concepts.each do |concept|
    storage.store_atom(concept)
    puts "Stored: #{concept}"
  end
  
  # Add some relationships
  cat_mammal = AtomSpace::InheritanceLink.new(concepts[0], concepts[1])
  cat_pet = AtomSpace::InheritanceLink.new(concepts[0], concepts[2])
  storage.store_atom(cat_mammal)
  storage.store_atom(cat_pet)
  
  # Show storage statistics
  stats = storage.get_stats
  puts "\nStorage statistics:"
  puts "  Type: #{stats["type"]}"
  puts "  Partition strategy: #{stats["partition_strategy"]}"
  puts "  Replication strategy: #{stats["replication_strategy"]}"
  puts "  Local atoms: #{stats["local_atoms"]}"
  puts "  Partition map size: #{stats["partition_map_size"]}"
  
  # Show distribution metrics
  metrics = storage.distribution_metrics
  puts "\nDistribution metrics:"
  puts "  Total atoms: #{metrics["total_atoms"]}"
  puts "  Balance score: #{metrics["balance_score"].as_f.round(3)}"
  
  storage.close
  cluster.stop
  puts "Storage demo completed"
  puts
end

# Example 3: Event handling and monitoring
def demo_event_monitoring
  puts "=== Demo 3: Event Monitoring ==="
  
  atomspace = AtomSpace.create_atomspace
  cluster = AtomSpace.create_distributed_cluster("events_demo", atomspace)
  
  # Set up event monitoring
  events_received = [] of String
  cluster.add_event_observer(->(event : AtomSpace::ClusterEvent, node_id : String) {
    event_msg = "Event: #{event} from node: #{node_id[0..7]}..."
    events_received << event_msg
    puts event_msg
  })
  
  puts "Starting cluster with event monitoring..."
  cluster.start
  
  # Give some time for startup events
  sleep 0.1
  
  # Add atoms to trigger sync events
  puts "Adding atoms to trigger synchronization..."
  cluster.add_atom(AtomSpace::ConceptNode.new("monitored_concept"))
  cluster.add_atom(AtomSpace::PredicateNode.new("monitored_predicate"))
  
  # Trigger manual synchronization
  puts "Triggering manual synchronization..."
  cluster.trigger_sync
  
  # Wait a bit for events to process
  sleep 0.1
  
  puts "Stopping cluster..."
  cluster.stop
  
  sleep 0.1
  
  puts "\nTotal events received: #{events_received.size}"
  events_received.each { |event| puts "  #{event}" }
  puts
end

# Example 4: Conflict resolution strategies
def demo_conflict_resolution
  puts "=== Demo 4: Conflict Resolution Strategies ==="
  
  strategies = [
    AtomSpace::SyncStrategy::LastWriteWins,
    AtomSpace::SyncStrategy::MergeUsingTruthValues,
    AtomSpace::SyncStrategy::VectorClock,
    AtomSpace::SyncStrategy::ConsensusVoting
  ]
  
  strategies.each do |strategy|
    puts "Testing strategy: #{strategy}"
    
    atomspace = AtomSpace.create_atomspace
    cluster = AtomSpace.create_distributed_cluster(
      cluster_id: "conflict_demo",
      atomspace: atomspace,
      sync_strategy: strategy
    )
    
    cluster.start
    
    # Create conflicting truth values
    tv1 = AtomSpace::SimpleTruthValue.new(0.8, 0.6)
    tv2 = AtomSpace::SimpleTruthValue.new(0.9, 0.7)
    
    concept1 = AtomSpace::ConceptNode.new("conflict_test", tv1)
    concept2 = AtomSpace::ConceptNode.new("conflict_test", tv2)
    
    # Add both - should trigger conflict resolution
    cluster.add_atom(concept1)
    cluster.add_atom(concept2)
    
    # Check the resolved truth value
    final_atom = atomspace.get_nodes_by_name("conflict_test", AtomSpace::AtomType::CONCEPT_NODE).first?
    if final_atom
      tv = final_atom.truth_value
      puts "  Resolved truth value: strength=#{tv.strength.round(3)}, confidence=#{tv.confidence.round(3)}"
    end
    
    cluster.stop
  end
  puts
end

# Example 5: Performance and load testing
def demo_performance_testing
  puts "=== Demo 5: Performance Testing ==="
  
  atomspace = AtomSpace.create_atomspace
  cluster = AtomSpace.create_distributed_cluster("perf_test", atomspace)
  cluster.start
  
  puts "Adding 1000 atoms to test performance..."
  start_time = Time.monotonic
  
  (1..1000).each do |i|
    concept = AtomSpace::ConceptNode.new("perf_concept_#{i}")
    cluster.add_atom(concept)
    
    if i % 100 == 0
      stats = cluster.cluster_stats
      puts "  #{i} atoms added, #{stats["pending_sync_operations"]} pending sync ops"
    end
  end
  
  end_time = Time.monotonic
  duration = (end_time - start_time).total_milliseconds
  
  puts "Performance results:"
  puts "  Total time: #{duration.round(2)} ms"
  puts "  Atoms per second: #{(1000.0 / duration * 1000).round(2)}"
  puts "  Final atomspace size: #{atomspace.size}"
  
  cluster.stop
  puts
end

# Main demonstration
def main
  puts "Distributed AtomSpace Clustering Demonstration"
  puts "=" * 50
  puts
  
  begin
    demo_basic_cluster
    demo_distributed_storage
    demo_event_monitoring
    demo_conflict_resolution
    demo_performance_testing
  rescue ex
    puts "Error during demonstration: #{ex.message}"
    puts ex.backtrace.join("\n")
  end
  
  puts "Demonstration completed!"
end

# Run the demonstration if this file is executed directly
if PROGRAM_NAME.includes?("demo")
  main
end