# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "pathname"

RSpec.describe RailsAgents::CLI do
  let(:root) { Pathname(Dir.mktmpdir) }

  before do
    allow_any_instance_of(described_class).to receive(:rails_root).and_return(root)
    FileUtils.mkdir_p(root.join("app/agents"))
  end

  after { FileUtils.remove_entry(root) }

  it "creates an Eve-shaped agent directory for the weather example" do
    expect {
      described_class.start(["new", "weather"])
    }.to output(/Created app\/agents\/weather/).to_stdout

    dir = root.join("app/agents/weather")
    expect(dir.join("instructions.md")).to be_file
    expect(dir.join("instructions.md").read).to include("weather brief")
    expect(dir.join("agent.json")).to be_file
    expect(dir.join("tools/fetch_forecast.rb")).to be_file
    expect(dir.join("tools/post_summary.rb")).to be_file
    expect(dir.join("skills/cities-and-units.md")).to be_file
    expect(dir.join("schedules/morning.yml")).to be_file
  end

  it "validates locally with test" do
    described_class.start(["new", "weather"])
    expect {
      described_class.start(["test", "weather"])
    }.to output(/Local validation passed/).to_stdout
  end
end
