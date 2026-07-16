# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAgents::Runner do
  class FakeProvider
    def initialize(responses) = @responses = responses

    def chat(**)
      @responses.shift
    end
  end

  class AddTool < RailsAgents::Tool
    description "Adds numbers"
    param :a, :number
    param :b, :number
    def call(a:, b:) = {sum: a + b}
  end

  class TestAgent < RailsAgents::Agent
    description "Adds numbers when asked"
    model "test-model"
    tools AddTool

    def self.provider_client
      @provider_client
    end

    def self.provider_client=(value)
      @provider_client = value
    end
  end

  it "returns a response from the provider" do
    TestAgent.provider_client = FakeProvider.new([
      RailsAgents::ProviderResponse.new(
        content: "hello",
        tool_calls: [],
        usage: RailsAgents::Usage.new(1, 1),
        finish_reason: "stop",
        content_blocks: nil,
        file_ids: [],
        assistant_raw_content: nil
      )
    ])

    result = RailsAgents::Runner.new(TestAgent, input: "hi").call
    expect(result.success).to be true
    expect(result.output).to eq("hello")
  end

  it "runs tools before finishing" do
    TestAgent.provider_client = FakeProvider.new([
      RailsAgents::ProviderResponse.new(
        content: nil,
        tool_calls: [RailsAgents::ToolCall.new(id: "1", name: "add", arguments: {"a" => 2, "b" => 3})],
        usage: RailsAgents::Usage.new(1, 0),
        finish_reason: "tool_calls",
        content_blocks: nil,
        file_ids: [],
        assistant_raw_content: nil
      ),
      RailsAgents::ProviderResponse.new(
        content: "5",
        tool_calls: [],
        usage: RailsAgents::Usage.new(1, 1),
        finish_reason: "stop",
        content_blocks: nil,
        file_ids: [],
        assistant_raw_content: nil
      )
    ])

    result = RailsAgents::Runner.new(TestAgent, input: "add 2 and 3").call
    expect(result.output).to eq("5")
  end

  it "requires a description" do
    agent = Class.new(RailsAgents::Agent)
    expect { agent.render_instructions }.to raise_error(RailsAgents::ConfigurationError, /description/)
  end

  it "requires a model" do
    agent = Class.new(RailsAgents::Agent) do
      description "Test agent"
    end
    expect { agent.resolved_model }.to raise_error(RailsAgents::ConfigurationError, /model/)
  end
end

RSpec.describe RailsAgents::Providers do
  it "builds known providers" do
    RailsAgents.config.openrouter_api_key = "test"
    expect(described_class.build(:openrouter)).to be_a(RailsAgents::Providers::OpenRouter)
  end
end
