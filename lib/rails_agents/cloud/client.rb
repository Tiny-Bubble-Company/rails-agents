# frozen_string_literal: true

require "faraday"
require "json"

module RailsAgents
  module Cloud
    class Client
      def initialize(config: RailsAgents.config)
        @config = config
      end

      def sync_agent(agent_id, manifest)
        put_json("/v1/agents/#{agent_id}", {
          app_id: @config.app_id,
          manifest: manifest
        }.compact)
      end

      def deploy_agent(agent_id)
        post_json("/v1/agents/#{agent_id}/deploy", {
          app_id: @config.app_id,
          environment: "production"
        }.compact)
      end

      def list_agents
        get_json("/v1/agents")
      end

      def agent_status(agent_id)
        get_json("/v1/agents/#{agent_id}")
      end

      def agent_runs(agent_id)
        get_json("/v1/agents/#{agent_id}/runs")
      end

      def billing_balance
        get_json("/v1/billing/balance")
      end

      def run_agent_id(agent_id, message:, **options)
        body = post_json("/v1/agents/#{agent_id}/run", {
          message: message,
          app_id: @config.app_id,
          parse_json: options[:parse_json],
          metadata: options[:metadata] || {}
        }.compact)

        to_result(body)
      end

      def run_agent(agent_class, message:, **options)
        agent_id = agent_id_for(agent_class)
        sync_class_agent!(agent_class, agent_id)
        run_agent_id(agent_id, message: message, **options)
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

      def to_result(body)
        Result.ok(
          output: body["output"],
          data: body["data"],
          messages: body["messages"] || [],
          usage: Usage.new(body.dig("usage", "input") || 0, body.dig("usage", "output") || 0),
          files: [],
          content_blocks: body["content_blocks"]
        )
      end

      def agent_id_for(agent_class)
        agent_class.name
          .to_s
          .split("::")
          .last
          .gsub(/Agent\z/, "")
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
      end

      def sync_class_agent!(agent_class, agent_id)
        instructions = agent_class.render_instructions
        sync_agent(agent_id, {
          "agent_id" => agent_id,
          "model" => agent_class.model_name || DirectoryAgent::DEFAULT_MODEL,
          "instructions" => instructions
        })
      rescue ConfigurationError
        nil
      end

      def post_json(path, payload)
        request_json(:post, path, payload)
      end

      def put_json(path, payload)
        request_json(:put, path, payload)
      end

      def get_json(path)
        request_json(:get, path, nil)
      end

      def request_json(method, path, payload)
        # Relative path so Faraday keeps "/api" from api_base (absolute "/v1/..." would drop it).
        relative = path.to_s.sub(%r{\A/}, "")
        response = connection.public_send(method, relative) do |req|
          req.headers["Authorization"] = "Bearer #{@config.require_api_key!}"
          req.headers["Content-Type"] = "application/json; charset=utf-8"
          req.headers["X-Rails-Agents-Environment"] = @config.environment
          unless payload.nil?
            req.body = JSON.generate(payload).encode("UTF-8")
          end
        end

        body = parse_body(response.body)

        if response.status == 402 || %w[payment_required subscription_required].include?(body.dig("error", "code"))
          raise PaymentRequired.new(
            body.dig("error", "message") || "Add Credits / subscribe to run agents on Rails Agents Cloud.",
            checkout_url: body.dig("error", "checkout_url") || body.dig("error", "subscribe_url")
          )
        end

        unless response.success?
          raise CloudError, "Cloud API #{response.status}: #{response.body}"
        end

        body
      end

      def connection
        base = @config.api_base.to_s
        base = "#{base}/" unless base.end_with?("/")
        @connection ||= Faraday.new(url: base) do |f|
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
