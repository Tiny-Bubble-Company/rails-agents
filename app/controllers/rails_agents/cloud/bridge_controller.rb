# frozen_string_literal: true

require "json"

module RailsAgents
  module Cloud
    class BridgeController < ActionController::API
      def create
        raw = request.raw_post
        Bridge::Signature.verify!(
          secret: RailsAgents.config.tool_bridge_secret,
          timestamp: request.headers["X-Rails-Agents-Timestamp"],
          body: raw,
          signature: request.headers["X-Rails-Agents-Signature"]
        )

        payload = JSON.parse(raw)
        tool_name = payload.fetch("tool")
        arguments = (payload["arguments"] || {}).transform_keys(&:to_sym)
        tool_class = resolve_tool!(tool_name)
        result = tool_class.new.call(**arguments)

        render json: {ok: true, result: result}
      rescue CloudError, ConfigurationError => error
        render json: {ok: false, error: {code: "bridge_error", message: error.message}}, status: :unauthorized
      rescue KeyError => error
        render json: {ok: false, error: {code: "bad_request", message: error.message}}, status: :bad_request
      rescue => error
        render json: {ok: false, error: {code: "tool_error", message: error.message}}, status: :ok
      end

      private

      def resolve_tool!(name)
        camel = name.to_s.camelize
        klass = camel.safe_constantize || "#{camel}Tool".safe_constantize
        raise CloudError, "unknown tool: #{name}" unless klass && klass < RailsAgents::Tool

        klass
      end
    end
  end
end
