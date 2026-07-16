# frozen_string_literal: true

module RailsAgents
  module Cloud
    class Session
      def self.for(agent_class)
        new(agent_class)
      end

      def initialize(agent_class, client: Client.new)
        @agent_class = agent_class
        @client = client
        @session_id = nil
        @continuation_token = nil
      end

      def create(message:)
        body = @client.create_session(@agent_class, message: message)
        @session_id = body["session_id"] || body["id"]
        @continuation_token = body["continuation_token"]
        body
      end

      def continue(message)
        raise ConfigurationError, "Call session.create first" unless @session_id && @continuation_token

        body = @client.continue_session(
          @session_id,
          message: message,
          continuation_token: @continuation_token
        )
        @continuation_token = body["continuation_token"] if body["continuation_token"]
        body
      end

      attr_reader :session_id, :continuation_token
    end
  end
end
