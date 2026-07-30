# frozen_string_literal: true

require "pathname"
require "active_support/core_ext/string/inflections"

module RailsAgents
  # Prefer product-facing typed subclasses: KnowledgeAgent, WorkflowAgent,
  # OperationsAgent, or MonitoringAgent.
  class Base
    class << self
      attr_reader :agent_name, :model_setting, :model_provider, :model_credential,
                  :memory_setting, :memory_provider, :memory_recall, :knowledge_glob,
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

      # model :gpt_5_mini, provider: :openai, credential: :company_openai
      # model :auto  # legacy cloud-routed default (still supported)
      def model(value, provider: nil, credential: nil)
        @model_setting = value
        @model_provider = provider
        @model_credential = credential
      end

      # memory :conversation, provider: :mem0, recall: 5
      def memory(value, provider: nil, recall: nil)
        @memory_setting = value
        @memory_provider = provider
        @memory_recall = recall
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

      # Declares a Pipedream SaaS connector (manifest lives under connectors/).
      # `plugin` remains as a deprecated alias.
      def connector(name, **opts)
        @connector_definitions ||= {}
        @connector_definitions[name.to_sym] = opts
      end
      alias_method :plugin, :connector

      def channel(kind)
        @channel_definitions ||= []
        @channel_definitions << kind.to_sym
      end

      def agent_directory
        @agent_directory ||= resolve_agent_directory
      end

      def run(message = nil, session_id: nil, client: nil, **inputs)
        text = coerce_run_message(message, inputs)
        new(client: client).run(text, session_id: session_id)
      end

      def deploy(client: nil)
        new(client: client).deploy
      end

      def sync_knowledge(client: nil)
        new(client: client).sync_knowledge
      end

      def coerce_run_message(message, inputs)
        if inputs.any?
          if !message.nil?
            raise ArgumentError, "pass either a message string or keyword inputs, not both"
          end

          inputs.map { |key, value| "#{key}: #{value}" }.join("\n")
        elsif message.nil?
          raise ArgumentError, "message is required (or pass keyword inputs like order_id:)"
        else
          message.to_s
        end
      end
      private :coerce_run_message

      def resolve_agent_directory
        caller_path = Pathname.new(caller_locations(1, 1).first.absolute_path)
        caller_path.dirname
      end
      private :resolve_agent_directory
    end

    def initialize(client: nil)
      @client = client || Client.new
    end

    def run(message = nil, session_id: nil, **inputs)
      text = self.class.send(:coerce_run_message, message, inputs)
      response = @client.create_run(
        agent: agent_identifier,
        message: text,
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
        kind: self.class.agent_kind,
        model: model_metadata,
        memory: memory_metadata,
        tools: self.class.tool_definitions&.keys || [],
        skills: self.class.skill_definitions || {},
        channels: self.class.channel_definitions || []
      }
    end

    def model_metadata
      setting = self.class.model_setting
      provider = self.class.model_provider
      credential = self.class.model_credential

      if provider.nil? && credential.nil?
        setting
      else
        {
          name: setting,
          provider: provider,
          credential: credential
        }.compact
      end
    end

    def memory_metadata
      setting = self.class.memory_setting
      provider = self.class.memory_provider
      recall = self.class.memory_recall

      if provider.nil? && recall.nil?
        setting
      else
        {
          type: setting,
          provider: provider,
          recall: recall
        }.compact
      end
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
      local = Dir.glob(dir.join(glob).to_s).map do |path|
        Pathname.new(path).relative_path_from(dir).to_s
      end
      (local + LibraryImports.new(dir).knowledge_paths).uniq
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
      # Legacy alias for output_text (Markdown final answer).
      def output
        text = output_text
        return text if text.is_a?(String) && !text.empty?

        final = nil
        chunks = []
        stream do |event|
          # Prefer terminal / normalized payloads (done / output events).
          if event["output_text"].is_a?(String) && !event["output_text"].empty?
            final = event["output_text"]
          elsif event["output"].is_a?(String) && !event["output"].empty? &&
                (event.key?("items") || event.key?("format") || event.key?("status"))
            final = event["output"]
          else
            piece = event["content"] || event["text"]
            chunks << piece if piece.is_a?(String) && !piece.empty?
          end
        end
        final || chunks.join
      end

      # Eve-aligned: final assistant Markdown (provider-agnostic).
      def output_text
        response["output_text"] ||
          dig_data("output_text") ||
          response["output"] ||
          dig_data("output")
      end

      # Optional structured final payload (when a schema/result was requested).
      def output_data
        response["output_data"] || dig_data("output_data")
      end

      # Typed turn items: message (+ optional result). Tool trail lives on #trace.
      def items
        response["items"] || dig_data("items") || []
      end

      def format
        response["format"] || dig_data("format") || "markdown"
      end

      def status
        response["status"] || dig_data("status")
      end

      def trace
        response["trace"] || dig_data("trace")
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
