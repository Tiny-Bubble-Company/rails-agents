# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "pathname"
require "tmpdir"

RSpec.describe RailsAgents::Base do
  let(:agent_dir) { Pathname.new(Dir.mktmpdir("agent")) }

  after do
    FileUtils.rm_rf(agent_dir)
  end

  let(:support_agent) do
    Class.new(described_class) do
      model :gpt_5_mini, provider: :openai, credential: :company_openai
      memory :conversation, provider: :mem0, recall: 5
      knowledge_from "knowledge/**/*"

      tool :lookup_order do |order_id:|
        { id: order_id, status: "shipped" }
      end

      skill :triage, from: "skills/triage.rb"
      channel :slack
    end.tap do |klass|
      klass.instance_variable_set(:@agent_directory, agent_dir)
    end
  end

  let(:client) { instance_double(RailsAgents::Client) }

  before do
    FileUtils.mkdir_p(agent_dir.join("knowledge"))
    File.write(agent_dir.join("knowledge/faq.md"), "# FAQ")
  end

  it "stores DSL configuration on the class" do
    expect(support_agent.model_setting).to eq(:gpt_5_mini)
    expect(support_agent.model_provider).to eq(:openai)
    expect(support_agent.model_credential).to eq(:company_openai)
    expect(support_agent.memory_setting).to eq(:conversation)
    expect(support_agent.memory_provider).to eq(:mem0)
    expect(support_agent.memory_recall).to eq(5)
    expect(support_agent.knowledge_glob).to eq("knowledge/**/*")
    expect(support_agent.tool_definitions.keys).to include(:lookup_order)
    expect(support_agent.skill_definitions[:triage]).to eq("skills/triage.rb")
    expect(support_agent.channel_definitions).to include(:slack)
  end

  it "supports legacy model :auto without provider metadata" do
    legacy = Class.new(described_class) { model :auto }
    instance = legacy.new(client: client)
    allow(client).to receive(:create_run).and_return({ "id" => "run_1" })

    legacy.new(client: client).run("Hi")

    expect(client).to have_received(:create_run).with(
      hash_including(metadata: hash_including(model: :auto, kind: :base))
    )
  end

  it "supports keyword trigger inputs like order_id:" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_kw" })

    support_agent.run(order_id: 1, client: client)

    expect(client).to have_received(:create_run).with(
      hash_including(message: "order_id: 1")
    )
  end

  it "rejects mixing a message string with keyword inputs" do
    expect {
      support_agent.run("hello", order_id: 1, client: client)
    }.to raise_error(ArgumentError, /either a message string or keyword/)
  end

  it "executes tool blocks" do
    result = support_agent.tool_definitions[:lookup_order].call(order_id: 42)
    expect(result[:status]).to eq("shipped")
  end

  it "collects knowledge paths relative to agent directory" do
    agent = support_agent.new(client: client)
    expect(agent.knowledge_paths).to eq(["knowledge/faq.md"])
  end

  it "includes kind and structured model in run metadata" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_abc" })

    support_agent.new(client: client).run("Hello", session_id: "sess_1")

    expect(client).to have_received(:create_run).with(
      hash_including(
        agent: agent_dir.basename.to_s,
        message: "Hello",
        session_id: "sess_1",
        metadata: hash_including(
          kind: :base,
          model: {
            name: :gpt_5_mini,
            provider: :openai,
            credential: :company_openai
          },
          memory: {
            type: :conversation,
            provider: :mem0,
            recall: 5
          }
        )
      )
    )
  end

  it "creates a run via the cloud client" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_abc" })

    result = support_agent.new(client: client).run("Hello", session_id: "sess_1")

    expect(result.run_id).to eq("run_abc")
  end

  it "deploys via the cloud client" do
    allow(client).to receive(:deploy).and_return({ "id" => "dep_1" })

    response = support_agent.new(client: client).deploy

    expect(client).to have_received(:deploy).with(
      agent: agent_dir.basename.to_s,
      bundle_path: agent_dir.to_s
    )
    expect(response["id"]).to eq("dep_1")
  end

  it "syncs knowledge via the cloud client" do
    allow(client).to receive(:sync_knowledge).and_return({ "synced" => 1 })

    support_agent.new(client: client).sync_knowledge

    expect(client).to have_received(:sync_knowledge).with(
      agent: agent_dir.basename.to_s,
      paths: ["knowledge/faq.md"]
    )
  end

  it "streams run output" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_1" })
    allow(client).to receive(:stream_run).and_yield({ "content" => "Hi" }).and_yield({ "content" => " there" })

    result = support_agent.run("Hello", client: client)
    expect(result.output).to eq("Hi there")
  end

  it "prefers done output_text over token chunks when draining stream" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_3" })
    allow(client).to receive(:stream_run)
      .and_yield({ "content" => "partial" })
      .and_yield({
        "output_text" => "Final markdown",
        "output" => "Final markdown",
        "format" => "markdown",
        "items" => [],
        "status" => "succeeded"
      })

    result = support_agent.run("Hello", client: client)
    expect(result.output).to eq("Final markdown")
  end

  it "exposes Eve-aligned output_text / items from sync create_run" do
    allow(client).to receive(:create_run).and_return({
      "object" => "run",
      "data" => {
        "id" => "run_2",
        "output" => "| Name | Qty |\n| --- | --- |\n| Tee | 2 |",
        "output_text" => "| Name | Qty |\n| --- | --- |\n| Tee | 2 |",
        "output_data" => nil,
        "items" => [
          {
            "type" => "message",
            "role" => "assistant",
            "content" => "| Name | Qty |\n| --- | --- |\n| Tee | 2 |",
            "format" => "markdown"
          }
        ],
        "format" => "markdown",
        "status" => "succeeded"
      }
    })

    result = support_agent.run("List products", client: client)
    expect(result.run_id).to eq("run_2")
    expect(result.output_text).to include("Tee")
    expect(result.output).to eq(result.output_text)
    expect(result.format).to eq("markdown")
    expect(result.items.first["type"]).to eq("message")
    expect(result.output_data).to be_nil
    expect(result.status).to eq("succeeded")
  end
end
