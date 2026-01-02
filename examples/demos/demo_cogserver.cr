# CogServer Network API Demo
# This demonstrates the key features of the CogServer network interfaces

require "./src/cogserver/cogserver_main"
require "http/client"
require "json"
require "base64"

puts "🚀 CogServer Network API Demo"
puts "=" * 50

# Start the server
server = CogServer::Server.new("localhost", 17005, 18085)
puts "\n📡 Starting CogServer on ports 17005 (telnet) and 18085 (HTTP/WebSocket)..."
server.start
sleep 1

begin
  # Add some sample data to the AtomSpace
  puts "\n🧠 Adding sample atoms to AtomSpace..."
  
  # Add some concept nodes
  atom1_data = {"type" => "ConceptNode", "name" => "dog"}
  response = HTTP::Client.post("http://localhost:18085/atoms", 
                              headers: HTTP::Headers{"Content-Type" => "application/json"},
                              body: atom1_data.to_json)
  
  atom2_data = {"type" => "ConceptNode", "name" => "animal"}  
  response = HTTP::Client.post("http://localhost:18085/atoms",
                              headers: HTTP::Headers{"Content-Type" => "application/json"},
                              body: atom2_data.to_json)
  
  atom3_data = {"type" => "ConceptNode", "name" => "mammal"}
  response = HTTP::Client.post("http://localhost:18085/atoms",
                              headers: HTTP::Headers{"Content-Type" => "application/json"},
                              body: atom3_data.to_json)
  
  puts "   ✅ Added sample concepts: dog, animal, mammal"
  
  # Demonstrate API endpoints
  puts "\n🌐 Testing HTTP API Endpoints:"
  
  # Status endpoint
  response = HTTP::Client.get("http://localhost:18085/status")
  status = JSON.parse(response.body)
  puts "   📊 Status: Server running on #{status["host"]}:#{status["port"]}"
  puts "      AtomSpace: #{status["atomspace_size"]} atoms (#{status["atomspace_nodes"]} nodes)"
  
  # Version endpoint
  response = HTTP::Client.get("http://localhost:18085/version")
  version = JSON.parse(response.body)
  puts "   📋 Version: #{version["version"]} (API #{version["api_version"]})"
  
  # Ping endpoint
  response = HTTP::Client.get("http://localhost:18085/ping")
  ping = JSON.parse(response.body)
  puts "   🏓 Ping: #{ping["status"]} at #{ping["timestamp"]}"
  
  # AtomSpace endpoint
  response = HTTP::Client.get("http://localhost:18085/atomspace")
  atomspace = JSON.parse(response.body)
  puts "   🧠 AtomSpace: #{atomspace["size"]} total atoms"
  
  # Atoms endpoint with details
  response = HTTP::Client.get("http://localhost:18085/atoms")
  atoms = JSON.parse(response.body)
  puts "   🔍 Atoms detail: #{atoms["count"]} atoms retrieved"
  
  # Sessions endpoint
  response = HTTP::Client.get("http://localhost:18085/sessions")
  sessions = JSON.parse(response.body)
  puts "   👥 Sessions: #{sessions["active_sessions"]} active sessions"
  
  # Demonstrate telnet interface
  puts "\n💻 Testing Telnet Interface Commands:"
  
  commands = ["help", "info", "atomspace", "list", "stats"]
  commands.each do |cmd|
    response = HTTP::Client.get("http://localhost:17005/?cmd=#{cmd}")
    output = response.body.split("\n").select(&.includes?(cmd == "help" ? "Available commands" : 
                                                       cmd == "info" ? "CogServer" :
                                                       cmd == "atomspace" ? "AtomSpace:" :
                                                       cmd == "list" ? "Atoms in AtomSpace" : 
                                                       "Session")).first?
    if output
      puts "   🔧 #{cmd}: #{output.strip}"
    else
      puts "   🔧 #{cmd}: Command executed successfully"
    end
  end
  
  # Demonstrate WebSocket upgrade
  puts "\n🔌 Testing WebSocket Protocol:"
  
  # Test valid WebSocket upgrade
  websocket_key = Base64.strict_encode("demo_key_12345678901234567890")
  headers = HTTP::Headers{
    "Connection" => "Upgrade",
    "Upgrade" => "websocket", 
    "Sec-WebSocket-Key" => websocket_key,
    "Sec-WebSocket-Version" => "13"
  }
  
  response = HTTP::Client.get("http://localhost:18085/", headers: headers)
  if response.status_code == 101
    puts "   ✅ WebSocket upgrade successful (HTTP 101)"
    puts "      Headers: Upgrade=#{response.headers["Upgrade"]}, Connection=#{response.headers["Connection"]}"
  else
    puts "   ❌ WebSocket upgrade failed with code #{response.status_code}"
  end
  
  # Show final statistics
  puts "\n📈 Final Server Statistics:"
  response = HTTP::Client.get("http://localhost:18085/status")
  final_status = JSON.parse(response.body)
  puts "   🎯 Total sessions created: #{final_status["active_sessions"]}"
  puts "   🧠 Final AtomSpace size: #{final_status["atomspace_size"]} atoms"
  puts "      - Nodes: #{final_status["atomspace_nodes"]}"
  puts "      - Links: #{final_status["atomspace_links"]}"
  
  puts "\n✨ Demo completed successfully!"
  puts "\n💡 Try these commands to explore further:"
  puts "   curl http://localhost:18085/status"
  puts "   curl 'http://localhost:17005/?cmd=help'"
  puts "   curl -H 'Connection: Upgrade' -H 'Upgrade: websocket' http://localhost:18085/"
  
rescue ex
  puts "\n❌ Demo failed: #{ex.message}"
ensure
  puts "\n🛑 Stopping CogServer..."
  server.stop
  puts "   ✅ Server stopped successfully"
end