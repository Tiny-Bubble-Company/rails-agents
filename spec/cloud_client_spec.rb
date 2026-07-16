# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe RailsAgents::Cloud::Client do
  before do
    RailsAgents.config.api_key = "rak_sandbox_test"
    RailsAgents.config.api_base = "https://api.example.test"
    RailsAgents.config.app_id = "app_123"
  end

  class WeatherAgent < RailsAgents::Agent
    model "anthropic/claude-sonnet-5"
    description "Weather helper"
  end

  it "posts a cloud run and returns a Result" do
    stub_request(:post, "https://api.example.test/v1/agents/weather/run")
      .with { |req|
        body = JSON.parse(req.body)
        expect(body["message"]).to eq("hi")
        expect(req.headers["Authorization"]).to eq("Bearer rak_sandbox_test")
        true
      }
      .to_return(
        status: 200,
        body: {output: "sunny", usage: {input: 1, output: 2}}.to_json,
        headers: {"Content-Type" => "application/json"}
      )

    result = WeatherAgent.run("hi")
    expect(result.success).to be true
    expect(result.output).to eq("sunny")
  end

  it "requires an API key" do
    RailsAgents.config.api_key = nil
    expect { WeatherAgent.run("hi") }.to raise_error(RailsAgents::ConfigurationError, /RAILS_AGENTS_API_KEY/)
  end
end

RSpec.describe RailsAgents::Cloud::Bridge::Signature do
  it "signs and verifies" do
    secret = "bridge_secret"
    body = '{"tool":"search_crm"}'
    timestamp = Time.now.to_i.to_s
    signature = described_class.sign(secret: secret, timestamp: timestamp, body: body)
    expect(described_class.verify!(secret: secret, timestamp: timestamp, body: body, signature: signature)).to be true
  end

  it "rejects bad signatures" do
    expect {
      described_class.verify!(
        secret: "bridge_secret",
        timestamp: Time.now.to_i.to_s,
        body: "{}",
        signature: "v1=deadbeef"
      )
    }.to raise_error(RailsAgents::Cloud::CloudError, /invalid bridge signature/)
  end
end

RSpec.describe RailsAgents::Configuration do
  it "infers sandbox environment from API key prefix" do
    config = described_class.new
    config.api_key = "rak_sandbox_abc"
    expect(config.environment).to eq("sandbox")
    config.api_key = "rak_live_abc"
    expect(config.environment).to eq("production")
  end
end
