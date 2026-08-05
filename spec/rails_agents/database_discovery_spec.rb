# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"
require "rails_agents/database_discovery"

RSpec.describe RailsAgents::DatabaseDiscovery do
  it "discovers ActiveRecord from database.yml and writes capability config" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "config"))
      File.write(
        File.join(dir, "config/database.yml"),
        <<~YAML
          development:
            adapter: postgresql
            database: demo_dev
        YAML
      )

      result = described_class.discover!(root: dir, live: false)
      expect(result.active_record).to eq(true)
      expect(result.mongoid).to eq(false)
      expect(result.default_attach).to eq(true)
      expect(result.adapters).to include("postgresql")

      data = described_class.load(dir)
      expect(data["default_attach"]).to eq(true)
      expect(data["engines"]).to include("active_record")
      expect(described_class.attached_by_default?(dir)).to eq(true)
      expect(described_class.sql_capable?(dir)).to eq(true)
    end
  end

  it "discovers Mongoid and marks mongo capable" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "config"))
      File.write(File.join(dir, "config/mongoid.yml"), "development:\n  clients:\n    default:\n      database: demo\n")

      result = described_class.discover!(root: dir, live: false)
      expect(result.mongoid).to eq(true)
      expect(result.default_attach).to eq(true)
      expect(described_class.mongoid_capable?(dir)).to eq(true)
    end
  end

  it "does not auto-attach when no database configs exist" do
    Dir.mktmpdir do |dir|
      FileUtils.mkdir_p(File.join(dir, "config"))
      result = described_class.discover!(root: dir, live: false)
      expect(result.default_attach).to eq(false)
      expect(described_class.attached_by_default?(dir)).to eq(false)
    end
  end
end
