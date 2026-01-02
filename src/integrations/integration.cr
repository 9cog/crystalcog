# Integration Module - Unified integration interface for CrystalCog
#
# This module provides a unified interface for all integration components:
# - CogPy/PyG Framework Integration
# - Pygmalion AI System
# - Galatea Frontend
# - Paphos Backend
# - Crystal Acceleration Engine

require "./cogpy_bridge"
require "./pyg_adapter"
require "./pygmalion_agent"
require "./galatea_frontend"
require "./paphos_connector"
require "./crystal_accelerator"
require "../cogutil/logger"
require "../atomspace/atomspace"

module CrystalCogIntegration
  VERSION = "0.1.0"

  # Main integration manager
  class Manager
    property cogpy_bridge : CogPyBridge::Bridge?
    property pyg_adapter : PygAdapter::Adapter?
    property pygmalion_agent : PygmalionAgent::Agent?
    property galatea_frontend : GalateaFrontend::Interface?
    property paphos_connector : PaphosBackend::Connector?
    property crystal_accelerator : CrystalAccelerator::Engine?
    property atomspace : AtomSpace::AtomSpace?
    
    def initialize
      @cogpy_bridge = nil
      @pyg_adapter = nil
      @pygmalion_agent = nil
      @galatea_frontend = nil
      @paphos_connector = nil
      @crystal_accelerator = nil
      @atomspace = nil
    end
    
    # Initialize all integration components
    def initialize_all_integrations(atomspace : AtomSpace::AtomSpace)
      CogUtil::Logger.info("Initializing all CrystalCog integrations")
      
      @atomspace = atomspace
      
      # Initialize CogPy bridge
      @cogpy_bridge = CogPyBridge.create_default_bridge
      @cogpy_bridge.not_nil!.attach_atomspace(atomspace)
      @cogpy_bridge.not_nil!.connect
      
      # Initialize PyG adapter
      @pyg_adapter = PygAdapter.create_default_adapter
      @pyg_adapter.not_nil!.attach_atomspace(atomspace)
      @pyg_adapter.not_nil!.initialize_backend
      
      # Initialize Pygmalion agent
      @pygmalion_agent = PygmalionAgent.create_default_agent
      @pygmalion_agent.not_nil!.attach_atomspace(atomspace)
      @pygmalion_agent.not_nil!.initialize_agent
      
      # Initialize Galatea frontend
      @galatea_frontend = GalateaFrontend.create_default_interface
      @galatea_frontend.not_nil!.attach_atomspace(atomspace)
      @galatea_frontend.not_nil!.initialize_interface
      
      # Initialize Paphos connector
      @paphos_connector = PaphosBackend.create_default_connector
      @paphos_connector.not_nil!.attach_atomspace(atomspace)
      @paphos_connector.not_nil!.initialize_connection
      
      # Initialize Crystal accelerator
      @crystal_accelerator = CrystalAccelerator.create_high_performance_engine
      @crystal_accelerator.not_nil!.attach_atomspace(atomspace)
      @crystal_accelerator.not_nil!.initialize_engine
      
      CogUtil::Logger.info("All integrations initialized successfully")
    end
    
    # Initialize only specific integrations
    def initialize_integration(
      integration_name : String,
      atomspace : AtomSpace::AtomSpace,
      config : Hash(String, String)? = nil
    )
      @atomspace = atomspace
      
      case integration_name
      when "cogpy"
        @cogpy_bridge = CogPyBridge.create_default_bridge
        @cogpy_bridge.not_nil!.attach_atomspace(atomspace)
        @cogpy_bridge.not_nil!.connect
        
      when "pyg"
        @pyg_adapter = PygAdapter.create_default_adapter
        @pyg_adapter.not_nil!.attach_atomspace(atomspace)
        @pyg_adapter.not_nil!.initialize_backend
        
      when "pygmalion"
        @pygmalion_agent = PygmalionAgent.create_default_agent
        @pygmalion_agent.not_nil!.attach_atomspace(atomspace)
        @pygmalion_agent.not_nil!.initialize_agent
        
      when "galatea"
        @galatea_frontend = GalateaFrontend.create_default_interface
        @galatea_frontend.not_nil!.attach_atomspace(atomspace)
        @galatea_frontend.not_nil!.initialize_interface
        
      when "paphos"
        @paphos_connector = PaphosBackend.create_default_connector
        @paphos_connector.not_nil!.attach_atomspace(atomspace)
        @paphos_connector.not_nil!.initialize_connection
        
      when "accelerator"
        @crystal_accelerator = CrystalAccelerator.create_high_performance_engine
        @crystal_accelerator.not_nil!.attach_atomspace(atomspace)
        @crystal_accelerator.not_nil!.initialize_engine
        
      else
        CogUtil::Logger.error("Unknown integration: #{integration_name}")
      end
    end
    
    # Get status of all integrations
    def get_integration_status : Hash(String, Hash(String, String))
      status = {} of String => Hash(String, String)
      
      if bridge = @cogpy_bridge
        status["cogpy"] = bridge.status
      end
      
      if adapter = @pyg_adapter
        status["pyg"] = adapter.status
      end
      
      if agent = @pygmalion_agent
        status["pygmalion"] = agent.status
      end
      
      if frontend = @galatea_frontend
        status["galatea"] = frontend.status
      end
      
      if connector = @paphos_connector
        status["paphos"] = connector.status
      end
      
      if accelerator = @crystal_accelerator
        status["accelerator"] = accelerator.status
      end
      
      status
    end
    
    # Execute integrated cognitive pipeline
    def execute_cognitive_pipeline(input : String) : Hash(String, String)
      CogUtil::Logger.info("Executing integrated cognitive pipeline")
      
      result = {} of String => String
      
      # Use accelerator for optimized processing
      if accelerator = @crystal_accelerator
        accelerator.execute_accelerated("cognitive_pipeline") do
          # Process through Pygmalion for conversational understanding
          if agent = @pygmalion_agent
            pygmalion_response = agent.chat(input)
            result["pygmalion_response"] = pygmalion_response
          end
          
          # Execute CogPy cognitive functions
          if bridge = @cogpy_bridge
            cognitive_data = bridge.send_cognitive_data({"input" => input})
            result["cogpy_processing"] = cognitive_data["status"]
          end
          
          # Store results in Paphos backend
          if connector = @paphos_connector
            connector.synchronize_state
            result["paphos_sync"] = "completed"
          end
          
          # Update Galatea frontend
          if frontend = @galatea_frontend
            frontend.ws_handlers.broadcast_state_update(result)
            result["galatea_update"] = "broadcasted"
          end
        end
      end
      
      result["status"] = "completed"
      result["timestamp"] = Time.utc.to_s
      result
    end
    
    # Shutdown all integrations
    def shutdown_all
      CogUtil::Logger.info("Shutting down all integrations")
      
      @cogpy_bridge.try &.disconnect
      @galatea_frontend.try &.stop
      @paphos_connector = nil
      @pygmalion_agent = nil
      @pyg_adapter = nil
      @crystal_accelerator = nil
      
      CogUtil::Logger.info("All integrations shut down")
    end
  end
  
  # Factory method for creating integration manager
  def self.create_manager : Manager
    Manager.new
  end
end
