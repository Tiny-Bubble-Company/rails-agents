# frozen_string_literal: true

require "pathname"
require "yaml"

module RailsAgents
  # Resolves workspace-shared capabilities declared by an agent's imports.yml.
  # Sources live under app/agents_library; sync uploads virtual agent-local
  # copies so the cloud runtime keeps its existing app/agents/<slug>/ contract.
  class LibraryImports
    class Error < StandardError; end

    Entry = Struct.new(:kind, :slug, :source, :target, keyword_init: true)

    KINDS = %w[tool skill plugin knowledge].freeze
    EXTENSIONS = {
      "tool" => ".rb",
      "skill" => ".rb",
      "plugin" => ".yml",
      "knowledge" => ".md"
    }.freeze

    attr_reader :agent_directory, :library_root

    def initialize(agent_directory, library_root: nil)
      @agent_directory = Pathname.new(agent_directory).expand_path
      @library_root = library_root ? Pathname.new(library_root).expand_path : default_library_root
    end

    def entries
      return [] unless manifest_path.file?

      document = YAML.safe_load(manifest_path.read, permitted_classes: [], aliases: false) || {}
      imports = document.fetch("imports", [])
      raise Error, "#{manifest_path} must contain an imports array" unless imports.is_a?(Array)

      imports.map { |raw| build_entry(raw) }
    rescue Psych::Exception => e
      raise Error, "Invalid #{manifest_path}: #{e.message}"
    end

    def virtual_files
      entries.map do |entry|
        raise Error, "Missing Library source: #{entry.source}" unless entry.source.file?

        {
          "path" => cloud_path(entry.target),
          "content" => entry.source.read,
          "library_source" => entry.source.relative_path_from(library_root).to_s
        }
      end
    end

    def knowledge_paths
      entries.select { |entry| entry.kind == "knowledge" }.map { |entry| entry.target.to_s }
    end

    private

    def manifest_path
      agent_directory.join("imports.yml")
    end

    def default_library_root
      agent_directory.parent.parent.join("agents_library")
    end

    def build_entry(raw)
      raise Error, "Each import in #{manifest_path} must be a mapping" unless raw.is_a?(Hash)

      kind = raw["kind"].to_s
      slug = normalize_slug(raw["slug"])
      raise Error, "Unsupported Library kind: #{kind.inspect}" unless KINDS.include?(kind)
      raise Error, "Library import slug is required" if slug.empty?

      from = raw["from"].to_s
      prefix = "library/"
      raise Error, "Library import #{slug} must use from: library/..." unless from.start_with?(prefix)

      source_relative = safe_relative(from.delete_prefix(prefix), "source")
      source = library_root.join(source_relative)
      target_relative = raw["as"].to_s.strip
      target_relative = default_target(kind, slug, source) if target_relative.empty?
      target = safe_relative(target_relative, "target")

      Entry.new(kind: kind, slug: slug, source: source, target: target)
    end

    def normalize_slug(value)
      value.to_s.downcase.gsub(/[^a-z0-9_]+/, "_").gsub(/\A_|_\z/, "")[0, 64]
    end

    def safe_relative(value, label)
      path = Pathname.new(value)
      clean = path.cleanpath
      if path.absolute? || clean.to_s == ".." || clean.to_s.start_with?("../")
        raise Error, "Library import #{label} must stay inside its root"
      end
      clean
    end

    def default_target(kind, slug, source)
      extension = source.extname
      extension = EXTENSIONS.fetch(kind) if extension.empty?
      folder = kind == "knowledge" ? "knowledge" : "#{kind}s"
      "#{folder}/#{slug}#{extension}"
    end

    def cloud_path(target)
      root = application_root
      agent_directory.join(target).relative_path_from(root).to_s
    end

    def application_root
      agent_directory.parent.parent.parent
    end
  end
end
