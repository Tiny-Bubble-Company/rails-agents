# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe RailsAgents::LibraryImports do
  around do |example|
    Dir.mktmpdir do |root|
      @root = Pathname.new(root)
      @agent_dir = @root.join("app/agents/support")
      @library_dir = @root.join("app/agents_library")
      FileUtils.mkdir_p(@agent_dir)
      FileUtils.mkdir_p(@library_dir)
      example.run
    end
  end

  it "builds virtual agent files from shared Library imports" do
    FileUtils.mkdir_p(@library_dir.join("skills"))
    @library_dir.join("skills/triage.rb").write("module Triage; end\n")
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: skill
          slug: triage
          from: library/skills/triage.rb
    YAML

    files = described_class.new(@agent_dir).virtual_files

    expect(files).to contain_exactly(
      hash_including(
        "path" => "app/agents/support/skills/triage.rb",
        "content" => "module Triage; end\n",
        "library_source" => "skills/triage.rb"
      )
    )
  end

  it "exposes imported knowledge at its agent-relative runtime path" do
    FileUtils.mkdir_p(@library_dir.join("knowledge"))
    @library_dir.join("knowledge/policy.md").write("# Policy\n")
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: knowledge
          slug: policy
          from: library/knowledge/policy.md
          as: knowledge/company/policy.md
    YAML

    imports = described_class.new(@agent_dir)

    expect(imports.knowledge_paths).to eq(["knowledge/company/policy.md"])
    expect(imports.virtual_files.first["path"]).to eq(
      "app/agents/support/knowledge/company/policy.md"
    )
  end

  it "rejects paths that escape the Library" do
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: tool
          slug: secret
          from: library/../../config/master.key
    YAML

    expect { described_class.new(@agent_dir).entries }
      .to raise_error(described_class::Error, /stay inside/)
  end

  it "does nothing for agents without imports" do
    imports = described_class.new(@agent_dir)

    expect(imports.entries).to eq([])
    expect(imports.virtual_files).to eq([])
  end
end
