# frozen_string_literal: true

require "json"
require "pathname"

module RailsAgents
  # Directory-first agent (Eve-shaped).
  #
  #   app/agents/weather/instructions.md   # required — a complete agent
  #   app/agents/weather/agent.json        # optional — { "model": "..." }
  #
  #   RailsAgents["weather"].run("What's the weather in Berlin?")
  #
  class DirectoryAgent
    DEFAULT_MODEL = "anthropic/claude-sonnet-4"

    attr_reader :id, :root

    def self.[](id)
      new(id)
    end

    def self.run(id, message, **options)
      new(id).run(message, **options)
    end

    def initialize(id, root: nil)
      @id = id.to_s
      @root = Pathname(root || default_root)
      raise ConfigurationError, "Missing agent directory: #{@root} (add instructions.md)" unless @root.directory?
      raise ConfigurationError, "Add #{@root.join("instructions.md")} — that file is a complete agent" unless instructions_path.file?
    end

    def instructions
      instructions_path.read(encoding: "UTF-8")
    end

    def model
      config.fetch("model", DEFAULT_MODEL)
    end

    def manifest
      files = {"instructions.md" => instructions}
      schedule_path = first_schedule_path
      if schedule_path
        rel = schedule_path.relative_path_from(root).to_s
        files[rel] = schedule_path.read
      end

      {
        "agent_id" => id,
        "model" => model,
        "instructions" => instructions,
        "schedule" => schedule_path&.read,
        "files" => files
      }.compact
    end

    def sync!(client: Cloud::Client.new)
      client.sync_agent(id, manifest)
    end

    def run(message, sync: true, **options)
      client = Cloud::Client.new
      sync!(client: client) if sync
      client.run_agent_id(id, message: message.to_s, **options)
    end

    alias ask run
    alias call run

    private

    def default_root
      raise ConfigurationError, "Rails root required (or pass root:)" unless defined?(::Rails) && ::Rails.respond_to?(:root)

      ::Rails.root.join("app/agents", id)
    end

    def instructions_path
      root.join("instructions.md")
    end

    def first_schedule_path
      Dir.glob(root.join("schedules/*.{yml,yaml}").to_s).map { |p| Pathname(p) }.min_by(&:to_s)
    end

    def config
      path = root.join("agent.json")
      return {} unless path.file?

      JSON.parse(path.read)
    rescue JSON::ParserError => error
      raise ConfigurationError, "Invalid agent.json in #{root}: #{error.message}"
    end
  end
end