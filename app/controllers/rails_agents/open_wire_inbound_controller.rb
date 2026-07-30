# frozen_string_literal: true

require "json"

module RailsAgents
  # Receives open-wire/1 message.inbound POSTs from the Open-Wire gateway.
  # Mounted under the Rails Agents engine (no separate OpenWire::Engine).
  #
  #   POST /agents/open_wire/inbound
  #   Headers: X-Open-Wire-Secret, X-Open-Wire-Protocol, X-Open-Wire-Installation
  #
  # Resolves agent via:
  #   ?agent=order_notification  OR  JSON meta / installation mapping in channels/*.yml
  class OpenWireInboundController < ApplicationController
    skip_forgery_protection

    def create
      slug = resolve_agent_slug
      return render json: { error: "agent is required (?agent=slug)" }, status: :bad_request if slug.blank?

      klass = load_agent_class(slug)
      return render json: { error: "Agent not found" }, status: :not_found unless klass

      secret = webhook_secret_for(slug)
      return render json: { error: "Open-Wire webhook secret not configured for agent" }, status: :unauthorized if secret.blank?

      message = RailsAgents::OpenWireAdapter.verify_inbound!(
        secret: secret,
        body: request.raw_post,
        headers: request.headers
      )

      result = dispatch_to_agent(klass, message, slug)

      render json: {
        object: "open_wire_inbound_ack",
        data: {
          agent: slug,
          message_id: message.id,
          thread_id: message.thread_id,
          result: result
        }
      }
    rescue ::OpenWire::AuthError => e
      render json: { error: e.message }, status: :unauthorized
    rescue ::OpenWire::WebhookError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("[RailsAgents::OpenWireInbound] #{e.class}: #{e.message}\n#{e.backtrace&.first(8)&.join("\n")}")
      render json: { error: "Inbound handler failed" }, status: :internal_server_error
    end

    private

    def resolve_agent_slug
      params[:agent].presence ||
        params[:agent_slug].presence ||
        request.headers["X-Rails-Agent-Slug"].presence
    end

    def webhook_secret_for(slug)
      yml = channel_yml(slug)
      return ENV["OPEN_WIRE_WEBHOOK_SECRET"].presence unless yml

      yml[/open_wire_webhook_secret:\s*["']?([^"'\s]+)/, 1].presence ||
        ENV["OPEN_WIRE_WEBHOOK_SECRET"].presence
    end

    def installation_id_for(slug)
      yml = channel_yml(slug)
      return nil unless yml

      yml[/open_wire_installation_id:\s*["']?([^"'\s]+)/, 1]
    end

    def channel_yml(slug)
      %w[slack.yml slack.yaml].each do |name|
        path = Rails.root.join("app", "agents", slug, "channels", name)
        return path.read if path.file?
      end
      nil
    end

    def dispatch_to_agent(klass, message, slug)
      # Prefer class-level on_channel_message callback when defined.
      if klass.respond_to?(:channel_message_handler) && klass.channel_message_handler
        return klass.channel_message_handler.call(message)
      end

      # Default: forward into agent run so Cloud/HITL loop can continue.
      run_message = [
        "open_wire_inbound:",
        "channel: #{message.channel}",
        "thread_id: #{message.thread_id}",
        "from: #{message.from_id}",
        "to: #{message.to_id}",
        "kind: #{message.to_kind}",
        "text: #{message.text}"
      ].join("\n")

      session_id = message.thread_id.present? ? "ow:#{message.thread_id}" : nil
      result = klass.run(run_message, session_id: session_id)

      maybe_auto_reply(slug, message, result)

      {
        mode: "agent_run",
        run_id: (result.respond_to?(:id) ? result.id : nil),
        output_preview: result.to_s.to_s[0, 240]
      }
    end

    def maybe_auto_reply(slug, message, result)
      installation_id = message.installation_id.presence || installation_id_for(slug)
      return unless installation_id && message.to_id.present?

      text =
        if result.respond_to?(:output)
          result.output.to_s
        else
          result.to_s
        end
      text = text.strip
      return if text.empty?

      # Cap auto-reply length for Slack
      text = text[0, 2800]
      RailsAgents::OpenWireAdapter.reply!(
        installation_id: installation_id,
        to: { id: message.to_id, kind: message.dm? ? "dm" : "channel" },
        text: text,
        thread_id: message.thread_id
      )
    rescue ::OpenWire::Error => e
      Rails.logger.warn("[RailsAgents::OpenWireInbound] auto-reply skipped: #{e.message}")
    end

    def load_agent_class(slug)
      safe_slug = slug.to_s
      return nil unless safe_slug.match?(/\A[a-zA-Z0-9_-]+\z/)

      path = Rails.root.join("app", "agents", safe_slug, "agent.rb")
      return nil unless path.file?

      source = path.read
      class_name = source[/class\s+([A-Z][A-Za-z0-9_:]*)\s*<\s*RailsAgents::/, 1]
      return nil unless class_name

      require_dependency path.to_s
      class_name.constantize
    end
  end
end
