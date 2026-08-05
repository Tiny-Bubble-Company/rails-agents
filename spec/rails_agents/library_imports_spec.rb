# frozen_string_literal: true

require "spec_helper"
require "tmpdir"
require "fileutils"

RSpec.describe RailsAgents::LibraryImports do
  around do |example|
    Dir.mktmpdir do |root|
      @root = Pathname.new(root)
      @agent_dir = @root.join("app/agents/support")
      @shared_dir = @root.join("app/agents/shared")
      FileUtils.mkdir_p(@agent_dir)
      FileUtils.mkdir_p(@shared_dir)
      example.run
    end
  end

  it "builds virtual agent files from app/agents/shared imports" do
    FileUtils.mkdir_p(@shared_dir.join("skills"))
    @shared_dir.join("skills/triage.rb").write("module Triage; end\n")
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: skill
          slug: triage
          from: shared/skills/triage.rb
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

  it "still resolves legacy from: library/ and app/agents_library/" do
    legacy = @root.join("app/agents_library")
    FileUtils.rm_rf(@shared_dir)
    FileUtils.mkdir_p(legacy.join("skills"))
    legacy.join("skills/triage.rb").write("module Triage; end\n")
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: skill
          slug: triage
          from: library/skills/triage.rb
    YAML

    files = described_class.new(@agent_dir).virtual_files

    expect(files.first["path"]).to eq("app/agents/support/skills/triage.rb")
  end

  it "exposes imported knowledge at its agent-relative runtime path" do
    FileUtils.mkdir_p(@shared_dir.join("knowledge"))
    @shared_dir.join("knowledge/policy.md").write("# Policy\n")
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: knowledge
          slug: policy
          from: shared/knowledge/policy.md
          as: knowledge/company/policy.md
    YAML

    imports = described_class.new(@agent_dir)

    expect(imports.knowledge_paths).to eq(["knowledge/company/policy.md"])
    expect(imports.virtual_files.first["path"]).to eq(
      "app/agents/support/knowledge/company/policy.md"
    )
  end

  it "rejects paths that escape the shared root" do
    @agent_dir.join("imports.yml").write(<<~YAML)
      version: 1
      imports:
        - kind: tool
          slug: secret
          from: shared/../../config/master.key
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
