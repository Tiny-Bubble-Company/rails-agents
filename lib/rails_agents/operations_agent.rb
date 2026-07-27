# frozen_string_literal: true

module RailsAgents
  # Coordinates unpredictable real-world work across people, tools, and changing conditions.
  class OperationsAgent < Base
    def self.agent_kind
      :operations
    end
  end
end
