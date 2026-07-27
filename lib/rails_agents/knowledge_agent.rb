# frozen_string_literal: true

module RailsAgents
  # Answers questions from your database, docs, and knowledge files (RAG).
  class KnowledgeAgent < Base
    def self.agent_kind
      :knowledge
    end
  end
end
