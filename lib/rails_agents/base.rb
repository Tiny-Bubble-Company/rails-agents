# frozen_string_literal: true

require "pathname"
require "active_support/core_ext/string/inflections"

module RailsAgents
  # Prefer typed subclasses for app integration:
  # ChatAgent, WorkflowAgent, or BackgroundAgent.
  class Base
    class << self
      attr_reader :agent_name, :model_setting, :memory_setting, :knowledge_glob,
                  :tool_definitions, :skill_definitions, :channel_definitions

      def agent_kind
        :base
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@tool_definitions, {})
        subclass.instance_variable_set(:@skill_definitions, {})
        subclass.instance_variable_set(:@channel_definitions, [])
      end

      def model(value)
        @model_setting = value
      end

      def memory(value)
        @memory_setting = value
      end

      def knowledge_from(glob)
        @knowledge_glob = glob
      end

      def tool(name, &block)
        @tool_definitions ||= {}
        @tool_definitions[name.to_sym] = block
      end

      def skill(name, from:)
        @skill_definitions ||= {}
        @skill_definitions[name.to_sym] = from
      end

      def channel(kind)
        @channel_definitions ||= []
        @channel_definitions << kind.to_sym
      end

      def agent_directory
        @agent_directory ||= resolve_agent_directory
      end

      def run(message, session_id: nil, client: nil)
        new(client: client).run(message, session_id: session_id)
      end

      def deploy(client: nil)
        new(client: client).deploy
      end

      def sync_knowledge(client: nil)
        new(client: client).sync_knowledge
      end

      private

      def resolve_agent_directory
        caller_path = Pathname.new(caller_locations(1, 1).first.absolute_path)
        caller_path.dirname
      end
    end

    def initialize(client: nil)
      @client = client || Client.new
    end

    def run(message, session_id: nil)
      response = @client.create_run(
        agent: agent_identifier,
        message: message,
        session_id: session_id,
        metadata: agent_metadata
      )

      RunResult.new(response, client: @client)
    end

    def deploy
      @client.deploy(agent: agent_identifier, bundle_path: self.class.agent_directory.to_s)
    end

    def sync_knowledge
      paths = knowledge_paths
      @client.sync_knowledge(agent: agent_identifier, paths: paths)
    end

    def agent_metadata
      {
        model: self.class.model_setting,
        memory: self.class.memory_setting,
        tools: self.class.tool_definitions&.keys || [],
        skills: self.class.skill_definitions || {},
        channels: self.class.channel_definitions || []
      }
    end

    def agent_identifier
      if self.class.name && !self.class.name.empty?
        self.class.name.underscore
      else
        self.class.agent_directory.basename.to_s
      end
    end

    def knowledge_paths
      glob = self.class.knowledge_glob
      return [] unless glob

      dir = self.class.agent_directory
      Dir.glob(dir.join(glob).to_s).map { |path| Pathname.new(path).relative_path_from(dir).to_s }
    end

    class RunResult
      attr_reader :response, :client

      def initialize(response, client:)
        @response = response
        @client = client
      end

      def run_id
        response["id"] ||
          response["run_id"] ||
          dig_data("id")
      end

      def stream(&block)
        client.stream_run(run_id, &block)
      end

      # Prefer the sync create_run body; otherwise drain the SSE stream.
      def output
        sync = response["output"] || dig_data("output")
        return sync if sync.is_a?(String) && !sync.empty?

        chunks = []
        stream do |event|
          piece = event["content"] || event["text"]
          chunks << piece if piece.is_a?(String) && !piece.empty?
        end
        chunks.join
      end

      private

      def dig_data(key)
        data = response["data"]
        data.is_a?(Hash) ? data[key] : nil
      end
    end
  end

  # Alias for PRD compatibility
  RailsAgent = RailsAgents unless defined?(RailsAgent)
end
