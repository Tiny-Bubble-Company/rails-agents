# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "pathname"

RSpec.describe RailsAgents::EnvFile do
  let(:root) { Pathname(Dir.mktmpdir) }

  after { FileUtils.remove_entry(root) }

  it "writes and loads credentials into ENV" do
    described_class.write_credentials!(
      root,
      api_key: "rak_sandbox_test",
      app_id: "app_123",
      bridge_secret: "bridge_secret"
    )

    ENV.delete("RAILS_AGENTS_API_KEY")
    ENV.delete("RAILS_AGENTS_APP_ID")
    ENV.delete("RAILS_AGENTS_BRIDGE_SECRET")

    parsed = described_class.load!(root)
    expect(parsed["RAILS_AGENTS_API_KEY"]).to eq("rak_sandbox_test")
    expect(ENV["RAILS_AGENTS_API_KEY"]).to eq("rak_sandbox_test")
    expect(ENV["RAILS_AGENTS_APP_ID"]).to eq("app_123")
  end

  it "updates existing keys without wiping other .env lines" do
    root.join(".env").write("FOO=bar\nRAILS_AGENTS_API_KEY=old\n")
    described_class.write_credentials!(
      root,
      api_key: "rak_live_new",
      app_id: "app_9",
      bridge_secret: "sec"
    )
    text = root.join(".env").read
    expect(text).to include("FOO=bar")
    expect(text).to include("RAILS_AGENTS_API_KEY=rak_live_new")
    expect(text).to include("RAILS_AGENTS_APP_ID=app_9")
  end
end
