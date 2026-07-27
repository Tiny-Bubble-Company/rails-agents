# frozen_string_literal: true

module RailsAgents
  # Legacy compatibility class. New output-producing agents should use WorkflowAgent.
  class CreationAgent < Base
    def self.agent_kind
      :creation
    end
  end
end
