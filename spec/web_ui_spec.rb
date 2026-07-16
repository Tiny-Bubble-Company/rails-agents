# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Rails Agents /agents Web UI config" do
  it "defaults tool bridge path to /agents/bridge" do
    expect(RailsAgents::Configuration.new.tool_bridge_path).to eq("/agents/bridge")
  end

  it "defaults dashboard_url to agents.meerkatagents.com" do
    expect(RailsAgents::Configuration.new.dashboard_url).to eq("https://agents.meerkatagents.com")
  end
end
