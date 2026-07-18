# frozen_string_literal: true

require "rails/generators/base"
require "rails/generators/named_base"

module RailsAgents
  module Generators
    class AgentGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("templates", __dir__)

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
        template "agent.rb.tt", File.join(agent_path, "agent.rb")
        template "prompt.md.tt", File.join(agent_path, "prompt.md")
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
    end
  end
end
