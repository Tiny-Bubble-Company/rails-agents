# frozen_string_literal: true

require "faraday"
require "json"

module RailsAgents
  module Cloud
    class Client
      def initialize(config: RailsAgents.config)
        @config = config
      end

      def run_agent(agent_class, message:, **options)
        agent_id = agent_id_for(agent_class)
        body = post_json("/v1/agents/#{agent_id}/run", {
          message: message,
          app_id: @config.app_id,
          parse_json: options[:parse_json],
          metadata: options[:metadata] || {}
        }.compact)

        Result.ok(
          output: body["output"],
          data: body["data"],
          messages: body["messages"] || [],
          usage: Usage.new(body.dig("usage", "input") || 0, body.dig("usage", "output") || 0),
          files: [],
          content_blocks: body["content_blocks"]
        )
      rescue CloudError => error
        Result.fail(error: error.message)
      end

      def create_session(agent_class, message:)
        agent_id = agent_id_for(agent_class)
        post_json("/v1/agents/#{agent_id}/sessions", {
          message: message,
          app_id: @config.app_id
        }.compact)
      end

      def continue_session(session_id, message:, continuation_token:)
        post_json("/v1/sessions/#{session_id}", {
          message: message,
          continuation_token: continuation_token
        })
      end

      private

      def agent_id_for(agent_class)
        agent_class.name
          .to_s
          .split("::")
          .last
          .gsub(/Agent\z/, "")
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end

      def post_json(path, payload)
        response = connection.post(path) do |req|
          req.headers["Authorization"] = "Bearer #{@config.require_api_key!}"
          req.headers["Content-Type"] = "application/json"
          req.headers["X-Rails-Agents-Environment"] = @config.environment
          req.body = JSON.generate(payload)
        end

        body = parse_body(response.body)

        if response.status == 402 || body.dig("error", "code") == "payment_required"
          raise PaymentRequired.new(
            body.dig("error", "message") || "Add Credits to run agents on Rails Agents Cloud.",
            checkout_url: body.dig("error", "checkout_url")
          )
        end

        unless response.success?
          raise CloudError, "Cloud API #{response.status}: #{response.body}"
        end

        body
      end

      def connection
        @connection ||= Faraday.new(url: @config.api_base) do |f|
          f.request :url_encoded
          f.adapter Faraday.default_adapter
        end
      end

      def parse_body(raw)
        JSON.parse(raw.to_s)
      rescue JSON::ParserError
        {}
      end
    end

    class CloudError < Error; end
  end
end
