require "spec"
require "../../src/integrations/integration"
require "../../src/atomspace/atomspace"
require "../../src/cogutil/logger"

describe CrystalCogIntegration::Manager do
  describe "#initialize" do
    it "creates a new integration manager" do
      manager = CrystalCogIntegration::Manager.new
      manager.should_not be_nil
    end
  end

  describe "#initialize_integration" do
    it "initializes cogpy integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("cogpy", atomspace)
      manager.cogpy_bridge.should_not be_nil
    end

    it "initializes pyg integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("pyg", atomspace)
      manager.pyg_adapter.should_not be_nil
    end

    it "initializes pygmalion integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("pygmalion", atomspace)
      manager.pygmalion_agent.should_not be_nil
    end

    it "initializes galatea integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("galatea", atomspace)
      manager.galatea_frontend.should_not be_nil
    end

    it "initializes paphos integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("paphos", atomspace)
      manager.paphos_connector.should_not be_nil
    end

    it "initializes accelerator integration" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_integration("accelerator", atomspace)
      manager.crystal_accelerator.should_not be_nil
    end
  end

  describe "#initialize_all_integrations" do
    it "initializes all integrations successfully" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      
      manager.initialize_all_integrations(atomspace)
      
      manager.cogpy_bridge.should_not be_nil
      manager.pyg_adapter.should_not be_nil
      manager.pygmalion_agent.should_not be_nil
      manager.galatea_frontend.should_not be_nil
      manager.paphos_connector.should_not be_nil
      manager.crystal_accelerator.should_not be_nil
    end
  end

  describe "#get_integration_status" do
    it "returns status for all initialized integrations" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      manager.initialize_all_integrations(atomspace)
      
      status = manager.get_integration_status
      
      status.should be_a(Hash(String, Hash(String, String)))
      status.size.should eq(6)
      status.has_key?("cogpy").should be_true
      status.has_key?("pyg").should be_true
      status.has_key?("pygmalion").should be_true
      status.has_key?("galatea").should be_true
      status.has_key?("paphos").should be_true
      status.has_key?("accelerator").should be_true
    end
  end

  describe "#execute_cognitive_pipeline" do
    it "executes complete cognitive pipeline" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      manager.initialize_all_integrations(atomspace)
      
      result = manager.execute_cognitive_pipeline("test input")
      
      result.should be_a(Hash(String, String))
      result["status"].should eq("completed")
      result.has_key?("timestamp").should be_true
    end
  end

  describe "#shutdown_all" do
    it "shuts down all integrations" do
      atomspace = AtomSpace::AtomSpace.new
      manager = CrystalCogIntegration::Manager.new
      manager.initialize_all_integrations(atomspace)
      
      manager.shutdown_all
      
      # After shutdown, integrations should be nil or disconnected
      # This is a basic check that shutdown doesn't raise errors
    end
  end
end

describe CrystalCogIntegration do
  describe ".create_manager" do
    it "creates a new integration manager" do
      manager = CrystalCogIntegration.create_manager
      manager.should be_a(CrystalCogIntegration::Manager)
    end
  end
end
