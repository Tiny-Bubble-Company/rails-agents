# frozen_string_literal: true

require "json"
require "net/http"
require "timeout"
require "uri"

module RailsAgents
  class ToolBridgeController < ApplicationController
    RailsAgents::Compat.skip_csrf!(self)

    RESERVED_SQL_TOOLS = %w[sql_query query_database].freeze

    def create
      return render json: { error: "Unauthorized" }, status: :unauthorized unless authorized_runtime?

      tool_name = params[:tool].to_s
      if RESERVED_SQL_TOOLS.include?(tool_name)
        return render_sql_query
      end

      klass = load_agent_class(params[:agent])
      tool = klass&.tool_definitions&.fetch(tool_name.to_sym, nil)
      return render json: { error: "Tool not found" }, status: :not_found unless tool

      arguments = request.request_parameters.presence || {}
      result = tool.call(**arguments.deep_symbolize_keys)
      render json: { ok: true, result: result }
    rescue ArgumentError => e
      render json: { error: e.message }, status: :unprocessable_entity
    rescue StandardError => e
      Rails.logger.error("[RailsAgents::ToolBridge] #{e.class}: #{e.message}")
      render json: { error: "Tool execution failed" }, status: :internal_server_error
    end

    private

    def render_sql_query
      arguments = request.request_parameters.presence || {}
      sql = (arguments["sql"] || arguments[:sql]).to_s.strip
      return render json: { ok: false, error: "sql is required" }, status: :unprocessable_entity if sql.empty?
      return render json: { ok: false, error: "ActiveRecord is not available" }, status: :unprocessable_entity unless defined?(ActiveRecord::Base)

      normalized = sql.sub(/;\s*\z/, "")
      unless normalized.match?(/\A\s*(WITH|SELECT)\b/im)
        return render json: { ok: false, error: "Only read-only SELECT/WITH queries are allowed" }, status: :unprocessable_entity
      end
      if normalized.match?(/\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE|COPY|EXECUTE|CALL)\b/i)
        return render json: { ok: false, error: "Write or DDL statements are not allowed" }, status: :unprocessable_entity
      end

      limited = normalized.match?(/\bLIMIT\b/i) ? normalized : "#{normalized} LIMIT 50"
      rows = ActiveRecord::Base.connection.exec_query(limited).to_a
      render json: { ok: true, result: { ok: true, row_count: rows.length, rows: rows.first(50) } }
    rescue StandardError => e
      Rails.logger.error("[RailsAgents::ToolBridge:sql_query] #{e.class}: #{e.message}")
      render json: { ok: false, error: e.message }, status: :unprocessable_entity
    end

    def authorized_runtime?
      token = request.authorization.to_s.sub(/\ABearer\s+/i, "")
      return false if token.empty?

      uri = URI("#{RailsAgents.config.api_v1_base}/auth/introspect")
      req = Net::HTTP::Get.new(uri)
      req["Authorization"] = "Bearer #{token}"
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https") do |http|
        http.open_timeout = 3
        http.read_timeout = 5
        http.request(req)
      end
      return false unless response.is_a?(Net::HTTPSuccess)

      body = JSON.parse(response.body)
      body.dig("data", "projectId").to_s == RailsAgents.config.project_id.to_s
    rescue JSON::ParserError, IOError, SystemCallError, Timeout::Error
      false
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
