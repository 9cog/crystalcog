# Galatea Frontend Interface - REST API and WebSocket handlers
#
# This module provides the interface for the Galatea frontend, including
# REST API endpoints and WebSocket handlers for real-time communication.

require "json"
require "../cogutil/logger"
require "../atomspace/atomspace"

module GalateaFrontend
  VERSION = "0.1.0"

  # Configuration for Galatea frontend
  class Config
    property host : String
    property port : Int32
    property websocket_port : Int32
    property cors_enabled : Bool
    property max_connections : Int32
    
    def initialize(
      @host = "0.0.0.0",
      @port = 3000,
      @websocket_port = 3001,
      @cors_enabled = true,
      @max_connections = 100
    )
    end
  end

  # REST API endpoint handlers
  class APIHandlers
    property atomspace : AtomSpace::AtomSpace?
    
    def initialize(@atomspace : AtomSpace::AtomSpace? = nil)
    end
    
    # Health check endpoint
    def handle_health_check : Hash(String, String)
      {
        "status" => "healthy",
        "service" => "galatea-frontend",
        "version" => VERSION
      }
    end
    
    # Get cognitive state
    def handle_get_state : Hash(String, String)
      CogUtil::Logger.debug("Handling get_state request")
      {
        "state" => "active",
        "atomspace_size" => @atomspace.nil? ? "0" : "unknown",
        "timestamp" => Time.utc.to_s
      }
    end
    
    # Query atoms from frontend
    def handle_atom_query(query : Hash(String, String)) : Array(Hash(String, String))
      CogUtil::Logger.info("Handling atom query: #{query}")
      [] of Hash(String, String)
    end
    
    # Execute cognitive action
    def handle_execute_action(action : Hash(String, String)) : Hash(String, String)
      CogUtil::Logger.info("Executing action: #{action["type"]?}")
      {
        "status" => "executed",
        "result" => "Action completed successfully"
      }
    end
    
    # Get visualization data
    def handle_get_visualization : Hash(String, Array(Hash(String, String)))
      CogUtil::Logger.debug("Generating visualization data")
      {
        "nodes" => [] of Hash(String, String),
        "edges" => [] of Hash(String, String)
      }
    end
  end

  # WebSocket handlers for real-time updates
  class WebSocketHandlers
    property atomspace : AtomSpace::AtomSpace?
    property active_connections : Int32
    
    def initialize(@atomspace : AtomSpace::AtomSpace? = nil)
      @active_connections = 0
    end
    
    # Handle new WebSocket connection
    def handle_connect(client_id : String)
      @active_connections += 1
      CogUtil::Logger.info("WebSocket client connected: #{client_id} (total: #{@active_connections})")
    end
    
    # Handle WebSocket disconnection
    def handle_disconnect(client_id : String)
      @active_connections -= 1
      CogUtil::Logger.info("WebSocket client disconnected: #{client_id} (remaining: #{@active_connections})")
    end
    
    # Handle incoming WebSocket message
    def handle_message(client_id : String, message : String) : String
      CogUtil::Logger.debug("Received WebSocket message from #{client_id}")
      # Process message and return response
      {
        "type" => "ack",
        "data" => "Message received"
      }.to_json
    end
    
    # Broadcast state update to all connected clients
    def broadcast_state_update(update : Hash(String, String))
      CogUtil::Logger.debug("Broadcasting state update to #{@active_connections} clients")
      # Broadcast logic will be implemented here
    end
    
    # Send atom update notification
    def notify_atom_update(atom_handle : Int32, update_type : String)
      CogUtil::Logger.debug("Notifying atom update: #{atom_handle} (#{update_type})")
      # Notification logic
    end
  end

  # Main Galatea frontend interface
  class Interface
    property config : Config
    property api_handlers : APIHandlers
    property ws_handlers : WebSocketHandlers
    property atomspace : AtomSpace::AtomSpace?
    
    def initialize(@config : Config)
      @atomspace = nil
      @api_handlers = APIHandlers.new
      @ws_handlers = WebSocketHandlers.new
    end
    
    # Initialize the frontend interface
    def initialize_interface : Bool
      CogUtil::Logger.info("Initializing Galatea frontend on #{@config.host}:#{@config.port}")
      true
    end
    
    # Attach AtomSpace for cognitive operations
    def attach_atomspace(atomspace : AtomSpace::AtomSpace)
      @atomspace = atomspace
      @api_handlers.atomspace = atomspace
      @ws_handlers.atomspace = atomspace
      CogUtil::Logger.info("Attached AtomSpace to Galatea frontend")
    end
    
    # Start the frontend server
    def start : Bool
      CogUtil::Logger.info("Starting Galatea frontend server")
      # Server startup logic
      true
    end
    
    # Stop the frontend server
    def stop : Bool
      CogUtil::Logger.info("Stopping Galatea frontend server")
      true
    end
    
    # Get frontend status
    def status : Hash(String, String)
      {
        "interface_status" => "running",
        "host" => @config.host,
        "port" => @config.port.to_s,
        "websocket_port" => @config.websocket_port.to_s,
        "active_connections" => @ws_handlers.active_connections.to_s,
        "cors_enabled" => @config.cors_enabled.to_s
      }
    end
  end
  
  # Factory method for creating interface with default configuration
  def self.create_default_interface : Interface
    config = Config.new
    Interface.new(config)
  end
  
  # Factory method for creating interface with custom ports
  def self.create_interface(host : String, port : Int32, ws_port : Int32) : Interface
    config = Config.new(host: host, port: port, websocket_port: ws_port)
    Interface.new(config)
  end
end
