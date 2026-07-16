# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"
require "tmpdir"
require "fileutils"
require "pathname"

RSpec.describe "rails-agents deploy" do
  let(:root) { Pathname(Dir.mktmpdir) }

  before do
    allow_any_instance_of(RailsAgents::CLI).to receive(:rails_root).and_return(root)
    allow_any_instance_of(RailsAgents::CLI).to receive(:open_url!)
    FileUtils.mkdir_p(root.join("app/agents"))
    RailsAgents.config = RailsAgents::Configuration.new
    ENV.delete("RAILS_AGENTS_API_KEY")
    ENV.delete("RAILS_AGENTS_APP_ID")
    ENV.delete("RAILS_AGENTS_BRIDGE_SECRET")
  end

  after { FileUtils.remove_entry(root) }

  it "signs up, writes .env, syncs+deploys, and opens /agents" do
    RailsAgents::CLI.start(["new", "weather"])

    stub_request(:post, "https://agents.meerkatagents.com/api/signup")
      .to_return(
        status: 200,
        body: {
          api_key: "rak_sandbox_abc",
          app_id: "app_abc",
          bridge_secret: "bridge_abc"
        }.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    stub_request(:put, "https://agents.meerkatagents.com/api/v1/agents/weather")
      .to_return(status: 200, body: {ok: true}.to_json, headers: {"Content-Type" => "application/json"})

    stub_request(:post, "https://agents.meerkatagents.com/api/v1/agents/weather/deploy")
      .to_return(
        status: 200,
        body: {status: "deployed", dashboard_url: "/dashboard/agents/weather"}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    opened = nil
    allow_any_instance_of(RailsAgents::CLI).to receive(:open_url!) { |_, url| opened = url }

    expect {
      RailsAgents::CLI.start([
        "deploy", "weather",
        "--email=dev@example.com",
        "--name=Dev Example"
      ])
    }.to output(/weather ready/).to_stdout

    env = root.join(".env").read
    expect(env).to include("RAILS_AGENTS_API_KEY=rak_sandbox_abc")
    expect(env).to include("RAILS_AGENTS_APP_ID=app_abc")
    expect(env).to include("RAILS_AGENTS_BRIDGE_SECRET=bridge_abc")
    expect(opened).to include("http://127.0.0.1:3000/agents")
    expect(opened).to include("key=rak_sandbox_abc")
  end
end
