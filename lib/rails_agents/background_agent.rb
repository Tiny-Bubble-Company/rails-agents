# frozen_string_literal: true

module RailsAgents
  # @deprecated Use {OperationsAgent} for async / scheduled agents.
  class BackgroundAgent < OperationsAgent
    def self.inherited(subclass)
      super
      warn "[RailsAgents] BackgroundAgent is deprecated; use OperationsAgent instead.", uplevel: 1
    end

    def self.agent_kind
      :operations
    end
  end
end
