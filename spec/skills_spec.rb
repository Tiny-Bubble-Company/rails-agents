# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAgents::SkillSet do
  def declaration(key, options = {})
    RailsAgents::SkillDeclaration.new(key: key, options: options)
  end

  it "maps web_search to Anthropic server tools" do
    set = described_class.new(declarations: [declaration(:web_search)], provider: :anthropic)
    request = set.anthropic_request

    expect(request[:server_tools]).to include({type: "web_search_20260209", name: "web_search"})
  end

  it "applies skill options to Anthropic server tools" do
    set = described_class.new(
      declarations: [declaration(:web_search, max_uses: 3, allowed_domains: ["example.com"])],
      provider: :anthropic
    )
    request = set.anthropic_request

    expect(request[:server_tools].first).to include(
      max_uses: 3,
      allowed_domains: ["example.com"]
    )
  end

  it "adds code_execution and files beta when a document skill is requested" do
    set = described_class.new(declarations: [declaration(:pptx)], provider: :anthropic)
    request = set.anthropic_request

    expect(request[:container][:skills]).to include({type: "anthropic", skill_id: "pptx", version: "latest"})
    expect(request[:server_tools].map { |tool| tool[:name] }).to include("code_execution")
    expect(request[:beta_headers]).to include("skills-2025-10-02", "files-api-2025-04-14")
  end

  it "uses portable tools on OpenAI" do
    set = described_class.new(declarations: [declaration(:web_search)], provider: :openai)
    expect(set.portable_tool_classes).to eq([RailsAgents::Skills::Portable::WebSearch])
  end

  it "rejects Anthropic-only skills on OpenAI" do
    expect {
      described_class.new(declarations: [declaration(:pptx)], provider: :openai).validate!
    }.to raise_error(RailsAgents::ConfigurationError, /pptx/)
  end

  it "accepts custom Anthropic skill ids" do
    set = described_class.new(declarations: [declaration("skill_abc123", version: "latest")], provider: :anthropic)
    expect(set.anthropic_request[:container][:skills]).to include(
      {type: "custom", skill_id: "skill_abc123", version: "latest"}
    )
  end

  it "rejects custom Anthropic skills on OpenAI" do
    expect {
      described_class.new(declarations: [declaration("skill_abc123")], provider: :openai).validate!
    }.to raise_error(RailsAgents::ConfigurationError, /Custom Anthropic skills/)
  end
end

RSpec.describe RailsAgents::Skills::AnthropicContent do
  it "extracts file ids from code execution results" do
    blocks = [{
      "type" => "code_execution_tool_result",
      "content" => {
        "type" => "code_execution_result",
        "content" => [{"type" => "file", "file_id" => "file_123"}]
      }
    }]

    expect(described_class.extract_file_ids(blocks)).to eq(["file_123"])
  end
end

RSpec.describe RailsAgents::Agent do
  class SkillTestAgent < RailsAgents::Agent
    provider :openai
    model "gpt-4o-mini"
    description "Test agent"
    skills :web_search, max_uses: 2
  end

  it "includes portable skill tools in the tool set" do
    expect(SkillTestAgent.tool_set.definitions.map { |d| d[:name] }).to include("web_search")
  end

  it "stores skill options on declarations" do
    expect(SkillTestAgent.skill_declarations.first.options).to include(max_uses: 2)
  end
end
