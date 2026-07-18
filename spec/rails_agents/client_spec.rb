# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAgents::Client do
  let(:config) do
    RailsAgents.config.tap do |c|
      c.api_key = "test-key"
      c.api_base = "https://meerkatagents.com"
      c.project_id = "proj_123"
    end
  end

  subject(:client) { described_class.new(config: config) }

  describe "#create_run" do
    it "POSTs to /api/v1/runs with auth" do
      stub_request(:post, "https://meerkatagents.com/api/v1/runs")
        .with(
          headers: { "Authorization" => "Bearer test-key" },
          body: hash_including("agent" => "support", "message" => "Hello")
        )
        .to_return(status: 200, body: { id: "run_1" }.to_json, headers: { "Content-Type" => "application/json" })

      response = client.create_run(agent: "support", message: "Hello")
      expect(response["id"]).to eq("run_1")
    end
  end

  describe "#deploy" do
    it "POSTs to /api/v1/deploys" do
      stub_request(:post, "https://meerkatagents.com/api/v1/deploys")
        .to_return(status: 200, body: { id: "dep_1", status: "queued" }.to_json)

      response = client.deploy(agent: "support")
      expect(response["status"]).to eq("queued")
    end
  end

  describe "#install_channel" do
    it "POSTs to /api/v1/channels/:kind/install" do
      stub_request(:post, "https://meerkatagents.com/api/v1/channels/slack/install")
        .to_return(status: 200, body: { url: "https://oauth.example" }.to_json)

      response = client.install_channel(kind: "slack")
      expect(response["url"]).to include("oauth")
    end
  end

  describe "#sync_knowledge" do
    it "POSTs to /api/v1/knowledge/sync" do
      stub_request(:post, "https://meerkatagents.com/api/v1/knowledge/sync")
        .to_return(status: 200, body: { synced: 2 }.to_json)

      response = client.sync_knowledge(agent: "support", paths: %w[faq.md])
      expect(response["synced"]).to eq(2)
    end
  end

  describe "#sync_files" do
    it "PUTs to /api/v1/agents/:id/files" do
      stub_request(:put, "https://meerkatagents.com/api/v1/agents/support/files")
        .with(body: hash_including("files" => kind_of(Array)))
        .to_return(status: 200, body: { data: [] }.to_json)

      response = client.sync_files(agent: "support", files: [{ "path" => "app/agents/support/agent.rb", "content" => "class Support; end" }])
      expect(response["data"]).to eq([])
    end
  end

  describe "#handshake" do
    it "POSTs to /api/v1/auth/handshake without bearer" do
      stub_request(:post, "https://meerkatagents.com/api/v1/auth/handshake")
        .with { |req| !req.headers["Authorization"] }
        .to_return(status: 201, body: { data: { api_key: "ra_x" } }.to_json)

      response = client.handshake(email: "a@b.com", password: "password1")
      expect(response.dig("data", "api_key")).to eq("ra_x")
    end
  end

  describe "#logs" do
    it "GETs /api/v1/logs" do
      stub_request(:get, %r{https://meerkatagents.com/api/v1/logs})
        .to_return(status: 200, body: { entries: [] }.to_json)

      expect(client.logs(agent: "support")["entries"]).to eq([])
    end
  end

  describe "#traces" do
    it "GETs /api/v1/traces" do
      stub_request(:get, %r{https://meerkatagents.com/api/v1/traces})
        .to_return(status: 200, body: { traces: [] }.to_json)

      expect(client.traces["traces"]).to eq([])
    end
  end

  describe "#evals" do
    it "GETs /api/v1/evals" do
      stub_request(:get, %r{https://meerkatagents.com/api/v1/evals})
        .to_return(status: 200, body: { evals: [] }.to_json)

      expect(client.evals["evals"]).to eq([])
    end
  end
end
