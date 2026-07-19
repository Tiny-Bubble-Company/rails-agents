# frozen_string_literal: true

module RailsAgents
  # Conversational request/response agents (controllers, chat UIs, helpdesks).
  # Call with +YourAgent.run(message, session_id: ...)+ and read +result.output+.
  class ChatAgent < Base
    def self.agent_kind
      :chat
    end
  end
end
