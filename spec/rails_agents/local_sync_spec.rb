# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe RailsAgents::LocalSync do
  let(:root) { Dir.mktmpdir }
  let(:client) { instance_double(RailsAgents::Client) }

  after { FileUtils.remove_entry(root) }

  before do
    RailsAgents.configure do |c|
      c.api_key = "rak_sandbox_test"
      c.api_base = "https://meerkatagents.com"
    end
  end

  describe "#pull!" do
    it "writes cloud files under app/agents/<slug>/" do
      allow(client).to receive(:get_agent).with(agent: "agt_1").and_return(
        {
          "data" => {
            "id" => "agt_1",
            "name" => "Support",
            "slug" => "support"
          }
        }
      )
      allow(client).to receive(:list_files).with(agent: "agt_1").and_return(
        {
          "data" => [
            { "path" => "agent.rb", "content" => "class Support < RailsAgents::Base; end\n" },
            { "path" => "instructions.md", "content" => "# Support\n" },
            { "path" => "tools/lookup.rb", "content" => "# tool\n" }
          ]
        }
      )

      result = described_class.new(client: client, root: root).pull!("agt_1")

      expect(result["ok"]).to eq(true)
      expect(result["slug"]).to eq("support")
      expect(result["count"]).to eq(3)
      expect(File.read(File.join(root, "app/agents/support/agent.rb"))).to include("RailsAgents::Base")
      expect(File.read(File.join(root, "app/agents/support/tools/lookup.rb"))).to include("tool")
    end

    it "rejects path traversal" do
      allow(client).to receive(:get_agent).and_return(
        { "data" => { "id" => "agt_1", "slug" => "support" } }
      )
      allow(client).to receive(:list_files).and_return(
        { "data" => [{ "path" => "../secrets.env", "content" => "nope" }] }
      )

      expect {
        described_class.new(client: client, root: root).pull!("agt_1")
      }.to raise_error(RailsAgents::LocalSync::Error, /Invalid path/)
    end
  end
end
