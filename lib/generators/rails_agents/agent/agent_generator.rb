# frozen_string_literal: true

require "rails/generators/base"
require "rails/generators/named_base"

module RailsAgents
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

      class_option :type,
        type: :string,
        default: "knowledge",
        desc: "Agent taxonomy: knowledge, workflow, operations, monitoring"

      class_option :database,
        type: :boolean,
        default: false,
        desc: "Scaffold database-connected tools (Knowledge agents)"

      desc "Scaffold an agent directory under app/agents/"

      def create_agent_directory
        empty_directory agent_path
        empty_directory File.join(agent_path, "tools")
        empty_directory File.join(agent_path, "skills")
        empty_directory File.join(agent_path, "knowledge")
        empty_directory File.join(agent_path, "channels")
        empty_directory File.join(agent_path, "evals")
      end

      def create_agent_files
        if database?
          template "agent_database.rb.tt", File.join(agent_path, "agent.rb")
          template "prompt_database.md.tt", File.join(agent_path, "prompt.md")
        else
          template "agent.rb.tt", File.join(agent_path, "agent.rb")
          template "prompt.md.tt", File.join(agent_path, "prompt.md")
        end
        template "memory.rb.tt", File.join(agent_path, "memory.rb")
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

      def database?
        options[:database]
      end
    end
  end
end
