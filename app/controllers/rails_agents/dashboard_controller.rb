# frozen_string_literal: true

require "yaml"

module RailsAgents
  class DashboardController < ApplicationController
    def show
      load_local_credentials!
      unless configured?
        redirect_to rails_agents.signup_path
        return
      end

      @embed_token = take_embed_token!
      @dashboard_url = build_embed_url("/dashboard", dashboard_query)
    end

    def proxy
      load_local_credentials!
      unless configured?
        redirect_to rails_agents.signup_path
        return
      end

      @embed_token = take_embed_token!
      path = "/dashboard/#{params[:path]}"
      @dashboard_url = build_embed_url(path, dashboard_query)
      render :show
    end

    private

    def take_embed_token!
      session.delete(:ra_embed_token).presence ||
        params[:embed_token].presence ||
        params[:token].presence
    end

    def load_local_credentials!
      path = Rails.root.join("config/rails_agents_credentials.yml")
      return unless path.exist?

      data = YAML.safe_load(path.read) || {}
      RailsAgents.configure do |config|
        config.api_key = data["api_key"] if data["api_key"].present?
        config.project_id = data["project_id"] if data["project_id"].present?
      end
    rescue Psych::SyntaxError
      nil
    end

    def dashboard_query
      request.query_parameters.except("embed_token", "token")
    end

    def build_embed_url(path, query = {})
      base = RailsAgents.config.dashboard_base.to_s.chomp("/")
      embed_query = query.merge("embed" => "1")
      dashboard_path = "#{path}?#{embed_query.to_query}"
      # Bootstrap sets the cloud session cookie, then redirects to a clean dashboard URL.
      if @embed_token.present?
        return "#{base}/api/v1/auth/embed?#{
          { token: @embed_token, next: dashboard_path }.to_query
        }"
      end

      "#{base}#{dashboard_path}"
    end
  end
end
