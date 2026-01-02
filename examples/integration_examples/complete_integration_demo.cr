# Integration Example - Complete demonstration of all integrations
#
# This example demonstrates how to use all CrystalCog integration components together

require "../../src/integrations/integration"
require "../../src/atomspace/atomspace"
require "../../src/cogutil/logger"

# Initialize logging
CogUtil::Logger.set_level(CogUtil::LogLevel::INFO)

puts "="*60
puts "CrystalCog Integration Example"
puts "="*60
puts ""

# Create AtomSpace
puts "1. Creating AtomSpace..."
atomspace = AtomSpace::AtomSpace.new

# Add some initial knowledge
dog = atomspace.add_concept_node("dog")
animal = atomspace.add_concept_node("animal")
atomspace.add_inheritance_link(dog, animal)

cat = atomspace.add_concept_node("cat")
atomspace.add_inheritance_link(cat, animal)

puts "   Added concepts: dog, cat, animal"
puts ""

# Create integration manager
puts "2. Creating Integration Manager..."
manager = CrystalCogIntegration.create_manager
puts "   Manager created"
puts ""

# Initialize individual integrations
puts "3. Initializing Individual Integrations..."

puts "   - Initializing CogPy bridge..."
manager.initialize_integration("cogpy", atomspace)

puts "   - Initializing PyG adapter..."
manager.initialize_integration("pyg", atomspace)

puts "   - Initializing Pygmalion agent..."
manager.initialize_integration("pygmalion", atomspace)

puts "   - Initializing Galatea frontend..."
manager.initialize_integration("galatea", atomspace)

puts "   - Initializing Paphos connector..."
manager.initialize_integration("paphos", atomspace)

puts "   - Initializing Crystal accelerator..."
manager.initialize_integration("accelerator", atomspace)

puts "   All integrations initialized!"
puts ""

# Check integration status
puts "4. Checking Integration Status..."
status = manager.get_integration_status

status.each do |name, component_status|
  puts "   #{name.upcase}:"
  component_status.each do |key, value|
    puts "     - #{key}: #{value}"
  end
  puts ""
end

# Execute cognitive pipeline
puts "5. Executing Integrated Cognitive Pipeline..."
input = "What is the relationship between dogs and animals?"
puts "   Input: #{input}"
puts ""

result = manager.execute_cognitive_pipeline(input)

puts "   Pipeline Results:"
result.each do |key, value|
  puts "     - #{key}: #{value}"
end
puts ""

# Demonstrate individual component usage
puts "6. Demonstrating Individual Component Usage..."
puts ""

# CogPy Bridge
if bridge = manager.cogpy_bridge
  puts "   CogPy Bridge:"
  data = {"query" => "analyze_concept", "concept" => "intelligence"}
  response = bridge.send_cognitive_data(data)
  puts "     Response: #{response["status"]}"
  puts ""
end

# Pygmalion Agent
if agent = manager.pygmalion_agent
  puts "   Pygmalion Agent:"
  chat_response = agent.chat("Explain cognitive architectures")
  puts "     Chat response: #{chat_response[0..80]}..."
  puts ""
end

# PyG Adapter
if adapter = manager.pyg_adapter
  puts "   PyG Adapter:"
  graph_data = adapter.export_atomspace_graph
  puts "     Exported graph structure ready for GNN processing"
  puts ""
end

# Crystal Accelerator
if accelerator = manager.crystal_accelerator
  puts "   Crystal Accelerator:"
  accelerator_status = accelerator.status
  puts "     Status: #{accelerator_status["engine_status"]}"
  puts "     Optimization level: #{accelerator_status["optimization_level"]}"
  puts ""
end

# Paphos Connector
if connector = manager.paphos_connector
  puts "   Paphos Backend:"
  sync_result = connector.synchronize_state
  puts "     State synchronized: #{sync_result}"
  puts ""
end

# Galatea Frontend
if frontend = manager.galatea_frontend
  puts "   Galatea Frontend:"
  frontend_status = frontend.status
  puts "     Interface status: #{frontend_status["interface_status"]}"
  puts "     Host: #{frontend_status["host"]}:#{frontend_status["port"]}"
  puts ""
end

# Shutdown
puts "7. Shutting Down Integrations..."
manager.shutdown_all
puts "   All integrations shut down successfully"
puts ""

puts "="*60
puts "Integration Example Complete!"
puts "="*60
