# frozen_string_literal: true

require "spec_helper"
require "pathname"

RSpec.describe "RailsAgents taxonomy" do
  let(:client) { instance_double(RailsAgents::Client) }

  before do
    allow(client).to receive(:create_run).and_return({ "id" => "run_1" })
  end

  {
    RailsAgents::KnowledgeAgent => :knowledge,
    RailsAgents::CreationAgent => :creation,
    RailsAgents::WorkflowAgent => :workflow,
    RailsAgents::OperationsAgent => :operations,
    RailsAgents::MonitoringAgent => :monitoring
  }.each do |klass, kind|
    it "#{klass.name} reports agent_kind #{kind}" do
      expect(klass.agent_kind).to eq(kind)
    end

    it "#{klass.name} sends kind in run metadata" do
      agent = Class.new(klass) do
        model :gpt_5_mini, provider: :openai, credential: :company_openai
      end
      agent.instance_variable_set(:@agent_directory, Pathname.new("/tmp/agents/demo"))

      agent.new(client: client).run("ping")

      expect(client).to have_received(:create_run).with(
        hash_including(metadata: hash_including(kind: kind))
      )
    end
  end

  it "ChatAgent is deprecated alias of Knowledge" do
    expect(RailsAgents::ChatAgent.agent_kind).to eq(:knowledge)
    expect(RailsAgents::ChatAgent).to be < RailsAgents::KnowledgeAgent
  end

  it "BackgroundAgent is deprecated alias of Operations" do
    expect(RailsAgents::BackgroundAgent.agent_kind).to eq(:operations)
    expect(RailsAgents::BackgroundAgent).to be < RailsAgents::OperationsAgent
  end

  it "defines TAXONOMY_TYPES constant" do
    expect(RailsAgents::TAXONOMY_TYPES).to eq(%i[knowledge workflow operations monitoring])
    expect(RailsAgents::LEGACY_TAXONOMY_TYPES).to eq(%i[creation])
  end
end
