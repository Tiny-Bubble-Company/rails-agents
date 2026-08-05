# frozen_string_literal: true

require "pathname"
require "yaml"

module RailsAgents
  # Resolves workspace-shared capabilities declared by an agent's imports.yml.
  # Sources live under app/agents/shared (preferred) or legacy app/agents_library.
  # Sync uploads virtual agent-local copies so the cloud runtime keeps its
  # existing app/agents/<slug>/ contract.
  class LibraryImports
    class Error < StandardError; end

    Entry = Struct.new(:kind, :slug, :source, :target, keyword_init: true)

    KINDS = %w[tool skill connector plugin knowledge package].freeze
    EXTENSIONS = {
      "tool" => ".rb",
      "skill" => ".rb",
      "connector" => ".yml",
      "plugin" => ".yml",
      "knowledge" => ".md",
      "package" => ".yml"
    }.freeze
    # Logical import prefixes → physical shared root (app/agents/shared).
    # "library/" kept for backwards-compatible imports.yml files.
    FROM_PREFIXES = %w[shared/ library/].freeze

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
      entries.flat_map do |entry|
        raise Error, "Missing shared source: #{entry.source}" unless entry.source.exist?

        if entry.kind == "package"
          package_virtual_files(entry)
        else
          raise Error, "Missing shared source: #{entry.source}" unless entry.source.file?

          [{
            "path" => cloud_path(entry.target),
            "content" => entry.source.read,
            "library_source" => entry.source.relative_path_from(library_root).to_s
          }]
        end
      end
    end

    def knowledge_paths
      entries.select { |entry| entry.kind == "knowledge" }.map { |entry| entry.target.to_s }
    end

    def self.resolve_library_root(agents_root)
      agents_root = Pathname.new(agents_root)
      shared = agents_root.join("shared")
      return shared if shared.exist?

      legacy = agents_root.parent.join("agents_library")
      return legacy if legacy.exist?

      shared
    end

    private

    def package_virtual_files(entry)
      root =
        if entry.source.directory?
          entry.source
        elsif entry.source.basename.to_s == "package.yml"
          entry.source.dirname
        else
          entry.source
        end
      raise Error, "Missing shared package directory: #{root}" unless root.directory?

      Dir.glob(root.join("**", "*").to_s).select { |path| File.file?(path) }.map do |path|
        file = Pathname.new(path)
        relative = file.relative_path_from(root)
        target = Pathname.new("packages/#{entry.slug}").join(relative)
        {
          "path" => cloud_path(target),
          "content" => file.read,
          "library_source" => file.relative_path_from(library_root).to_s
        }
      end
    end

    def manifest_path
      agent_directory.join("imports.yml")
    end

    def default_library_root
      self.class.resolve_library_root(agent_directory.parent)
    end

    def build_entry(raw)
      raise Error, "Each import in #{manifest_path} must be a mapping" unless raw.is_a?(Hash)

      kind = raw["kind"].to_s
      kind = "connector" if kind == "plugin"
      slug = normalize_slug(raw["slug"])
      raise Error, "Unsupported shared kind: #{kind.inspect}" unless KINDS.include?(kind)
      raise Error, "Shared import slug is required" if slug.empty?

      from = raw["from"].to_s
      prefix = FROM_PREFIXES.find { |p| from.start_with?(p) }
      unless prefix
        raise Error,
          "Shared import #{slug} must use from: shared/... (or legacy library/...)"
      end

      source_relative = safe_relative(from.delete_prefix(prefix), "source")
      source = library_root.join(source_relative)
      if kind == "connector" && !source.exist? && source_relative.to_s.start_with?("connectors/")
        legacy = source_relative.to_s.sub(/\Aconnectors\//, "plugins/")
        legacy_source = library_root.join(legacy)
        source = legacy_source if legacy_source.exist?
      end
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
        raise Error, "Shared import #{label} must stay inside its root"
      end
      clean
    end

    def default_target(kind, slug, source)
      extension = source.extname
      extension = EXTENSIONS.fetch(kind) if extension.empty?
      case kind
      when "knowledge"
        "knowledge/#{slug}#{extension}"
      when "package"
        "packages/#{slug}/package.yml"
      when "connector", "plugin"
        "connectors/#{slug}#{extension}"
      else
        "#{kind}s/#{slug}#{extension}"
      end
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
