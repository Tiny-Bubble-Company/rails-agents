# frozen_string_literal: true

module RailsAgents
  # Multi-step orchestration agents (onboarding, lead qualification, pipelines).
  # Prefer a stable +session_id+ so each step continues the same run context.
  class WorkflowAgent < Base
    def self.agent_kind
      :workflow
    end
  end
end
