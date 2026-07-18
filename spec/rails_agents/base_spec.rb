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
      model :auto
      memory :conversation
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
    expect(support_agent.model_setting).to eq(:auto)
    expect(support_agent.memory_setting).to eq(:conversation)
    expect(support_agent.knowledge_glob).to eq("knowledge/**/*")
    expect(support_agent.tool_definitions.keys).to include(:lookup_order)
    expect(support_agent.skill_definitions[:triage]).to eq("skills/triage.rb")
    expect(support_agent.channel_definitions).to include(:slack)
  end

  it "executes tool blocks" do
    result = support_agent.tool_definitions[:lookup_order].call(order_id: 42)
    expect(result[:status]).to eq("shipped")
  end

  it "collects knowledge paths relative to agent directory" do
    agent = support_agent.new(client: client)
    expect(agent.knowledge_paths).to eq(["knowledge/faq.md"])
  end

  it "creates a run via the cloud client" do
    allow(client).to receive(:create_run).and_return({ "id" => "run_abc" })

    result = support_agent.new(client: client).run("Hello", session_id: "sess_1")

    expect(client).to have_received(:create_run).with(
      hash_including(
        agent: agent_dir.basename.to_s,
        message: "Hello",
        session_id: "sess_1"
      )
    )
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
end
