# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "webmock/rspec"

RSpec.describe "Anthropic skills integration" do
  class ReportAgent < RailsAgents::Agent
    provider :anthropic
    model "claude-sonnet-4-20250514"
    description "Create a spreadsheet."
    skills :xlsx
  end

  class FakeAnthropicProvider
    attr_reader :files

    def initialize(response_body:, file_bytes: "excel-bytes")
      @response_body = response_body
      @file_bytes = file_bytes
      @files = Class.new do
        define_method(:initialize) { |parent| @parent = parent }
        define_method(:download) do |file_id|
          RailsAgents::GeneratedFile.new(
            file_id: file_id,
            filename: "report.xlsx",
            content_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
            data: @parent.instance_variable_get(:@file_bytes),
            path: nil
          )
        end
      end.new(self)
    end

    def chat(**)
      data = JSON.parse(@response_body)
      blocks = data.fetch("content")
      RailsAgents::ProviderResponse.new(
        content: RailsAgents::Skills::AnthropicContent.extract_text(blocks),
        tool_calls: [],
        usage: RailsAgents::Usage.new(10, 20),
        finish_reason: data["stop_reason"],
        content_blocks: blocks,
        file_ids: RailsAgents::Skills::AnthropicContent.extract_file_ids(blocks),
        assistant_raw_content: blocks
      )
    end
  end

  let(:response_body) do
    {
      stop_reason: "end_turn",
      content: [
        {type: "text", text: "Created your spreadsheet."},
        {
          type: "code_execution_tool_result",
          content: {
            type: "code_execution_result",
            content: [{type: "file", file_id: "file_123"}]
          }
        }
      ],
      usage: {input_tokens: 10, output_tokens: 20}
    }.to_json
  end

  it "downloads generated files and exposes them on the result" do
    body = response_body
    ReportAgent.define_singleton_method(:provider_client) do
      FakeAnthropicProvider.new(response_body: body)
    end

    Dir.mktmpdir do |dir|
      result = ReportAgent.run("Build a sales report", save_files_to: dir)

      expect(result.success).to be true
      expect(result.output).to include("spreadsheet")
      expect(result.files.size).to eq(1)
      expect(result.files.first.filename).to eq("report.xlsx")
      expect(result.files.first.path).to eq(File.join(dir, "report.xlsx"))
      expect(File.binread(result.files.first.path)).to eq("excel-bytes")
    end
  end
end

RSpec.describe RailsAgents::Providers::Anthropic::Files do
  it "downloads file content from the Files API" do
    stub_request(:get, "https://api.anthropic.com/v1/files/file_123")
      .to_return(status: 200, body: {id: "file_123", filename: "report.xlsx", mime_type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"}.to_json)
    stub_request(:get, "https://api.anthropic.com/v1/files/file_123/content")
      .to_return(status: 200, body: "excel-bytes", headers: {"Content-Type" => "application/octet-stream"})

    file = described_class.new(api_key: "test").download("file_123")

    expect(file.filename).to eq("report.xlsx")
    expect(file.data).to eq("excel-bytes")
  end
end

RSpec.describe RailsAgents::Providers::Anthropic do
  it "requests document skills with required beta headers" do
    stub_request(:post, "https://api.anthropic.com/v1/messages")
      .with { |request|
        body = JSON.parse(request.body)
        headers = request.headers
        body.dig("container", "skills")&.any? { |skill| skill["skill_id"] == "pptx" } &&
          headers["Anthropic-Beta"].to_s.include?("skills-2025-10-02") &&
          headers["Anthropic-Beta"].to_s.include?("files-api-2025-04-14")
      }
      .to_return(status: 200, body: {
        stop_reason: "end_turn",
        content: [{type: "text", text: "Done"}],
        usage: {input_tokens: 1, output_tokens: 1}
      }.to_json)

    skills = RailsAgents::SkillSet.new(
      declarations: [RailsAgents::SkillDeclaration.new(key: :pptx, options: {})],
      provider: :anthropic
    )

    described_class.new(api_key: "test").chat(
      messages: [RailsAgents::Message.user("Create slides")],
      client_tools: [],
      skills: skills,
      model: "claude-sonnet-4-20250514"
    )
  end
end
