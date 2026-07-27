# frozen_string_literal: true

module RailsAgents
  # @deprecated Use {KnowledgeAgent} for conversational / Q&A agents.
  class ChatAgent < KnowledgeAgent
    def self.inherited(subclass)
      super
      warn "[RailsAgents] ChatAgent is deprecated; use KnowledgeAgent instead.", uplevel: 1
    end

    def self.agent_kind
      :knowledge
    end
  end
end
