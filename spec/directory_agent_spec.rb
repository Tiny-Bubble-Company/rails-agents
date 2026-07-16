# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"
require "tmpdir"
require "fileutils"

RSpec.describe RailsAgents::DirectoryAgent do
  let(:agent_root) { Pathname(Dir.mktmpdir) }

  before do
    RailsAgents.config.api_key = "rak_sandbox_test"
    RailsAgents.config.api_base = "https://api.example.test"
    RailsAgents.config.app_id = "app_123"

    FileUtils.mkdir_p(agent_root)
    File.write(agent_root.join("instructions.md"), "# Identity\n\nYou are a weather expert.\n")
    File.write(agent_root.join("agent.json"), JSON.generate("model" => "anthropic/claude-sonnet-4"))
  end

  after { FileUtils.remove_entry(agent_root) }

  it "treats instructions.md as a complete agent" do
    agent = described_class.new("weather", root: agent_root)
    expect(agent.instructions).to include("weather expert")
    expect(agent.model).to eq("anthropic/claude-sonnet-4")
  end

  it "syncs then runs through Cloud" do
    stub_request(:put, "https://api.example.test/v1/agents/weather")
      .with { |req|
        body = JSON.parse(req.body)
        expect(body.dig("manifest", "instructions")).to include("weather expert")
        true
      }
      .to_return(status: 200, body: {ok: true}.to_json, headers: {"Content-Type" => "application/json"})

    stub_request(:post, "https://api.example.test/v1/agents/weather/run")
      .with { |req|
        expect(JSON.parse(req.body)["message"]).to eq("Berlin?")
        true
      }
      .to_return(
        status: 200,
        body: {output: "sunny", usage: {input: 3, output: 4}}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = described_class.new("weather", root: agent_root).run("Berlin?")
    expect(result.success).to be true
    expect(result.output).to eq("sunny")
  end

  it "raises when instructions.md is missing" do
    FileUtils.rm(agent_root.join("instructions.md"))
    expect {
      described_class.new("weather", root: agent_root)
    }.to raise_error(RailsAgents::ConfigurationError, /instructions\.md/)
  end
end
