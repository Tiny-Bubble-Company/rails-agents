# frozen_string_literal: true

require "rails/generators/base"
require "rails/generators/named_base"

module RailsAgents
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      RESERVED_SLUGS = %w[shared library].freeze

      class_option :type,
        type: :string,
        default: "knowledge",
        desc: "Agent taxonomy: knowledge, workflow, operations, monitoring"

      class_option :database,
        type: :boolean,
        default: nil,
        desc: "Attach full-database knowledge + query tools (default: on when install detected a DB). Use --no-database to skip."

      desc "Scaffold an agent directory under app/agents/"

      def create_agent_directory
        if RESERVED_SLUGS.include?(file_name)
          raise Thor::Error,
            "Agent name #{file_name.inspect} is reserved for app/agents/shared/. Choose another name."
        end

        empty_directory agent_path
        empty_directory File.join(agent_path, "tools")
        empty_directory File.join(agent_path, "skills")
        empty_directory File.join(agent_path, "knowledge")
        empty_directory File.join(agent_path, "connectors")
        empty_directory File.join(agent_path, "plugins")
        empty_directory File.join(agent_path, "channels")
        empty_directory File.join(agent_path, "evals")
      end

      def create_agent_files
        if attach_database?
          template "agent_database.rb.tt", File.join(agent_path, "agent.rb")
          template "prompt_database.md.tt", File.join(agent_path, "prompt.md")
          empty_directory File.join(agent_path, "knowledge", "sources")
          template "knowledge/sources/rails_database.yml.tt",
            File.join(agent_path, "knowledge", "sources", "rails_database.yml")
        else
          template "agent.rb.tt", File.join(agent_path, "agent.rb")
          template "prompt.md.tt", File.join(agent_path, "prompt.md")
        end
        template "memory.rb.tt", File.join(agent_path, "memory.rb")
        template "imports.yml.tt", File.join(agent_path, "imports.yml")
        template "channels/slack.rb.tt", File.join(agent_path, "channels/slack.rb")
        template "evals/smoke.yml.tt", File.join(agent_path, "evals/smoke.yml")
      end

      private

      def agent_path
        File.join("app/agents", file_name)
      end

      def class_name
        name.camelize
      end

      def agent_type
        type = options[:type].to_s.downcase
        return type if RailsAgents::TAXONOMY_TYPES.map(&:to_s).include?(type)

        say "Unknown --type #{options[:type].inspect}; using knowledge.", :yellow
        "knowledge"
      end

      def agent_base_class
        {
          "knowledge" => "KnowledgeAgent",
          "workflow" => "WorkflowAgent",
          "operations" => "OperationsAgent",
          "monitoring" => "MonitoringAgent"
        }.fetch(agent_type)
      end

      def attach_database?
        return false if options[:database] == false
        return true if options[:database] == true

        require "rails_agents/database_discovery"
        RailsAgents::DatabaseDiscovery.attached_by_default?(destination_root)
      rescue StandardError
        true
      end

      def include_sql_query?
        require "rails_agents/database_discovery"
        data = RailsAgents::DatabaseDiscovery.load(destination_root)
        return true if data.nil?

        RailsAgents::DatabaseDiscovery.sql_capable?(destination_root) ||
          !RailsAgents::DatabaseDiscovery.mongoid_capable?(destination_root)
      rescue StandardError
        true
      end

      def include_mongo_query?
        require "rails_agents/database_discovery"
        RailsAgents::DatabaseDiscovery.mongoid_capable?(destination_root)
      rescue StandardError
        false
      end

      def discovery_engines
        require "rails_agents/database_discovery"
        data = RailsAgents::DatabaseDiscovery.load(destination_root)
        engines = Array(data && data["engines"]).map(&:to_s)
        return engines if engines.any?

        list = []
        list << "active_record" if include_sql_query?
        list << "mongoid" if include_mongo_query?
        list.presence || %w[active_record]
      rescue StandardError
        %w[active_record]
      end
    end
  end
end
