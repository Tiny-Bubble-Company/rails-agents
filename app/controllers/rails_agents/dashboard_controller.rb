# frozen_string_literal: true

require "yaml"

module RailsAgents
  class DashboardController < ApplicationController
    def show
      load_local_credentials!
      @embed_token = params[:embed_token].presence || params[:token].presence
      @dashboard_url = build_embed_url("/dashboard")
    end

    def proxy
      load_local_credentials!
      @embed_token = params[:embed_token].presence || params[:token].presence
      path = "/dashboard/#{params[:path]}"
      @dashboard_url = build_embed_url(path)
      render :show
    end

    private

    def load_local_credentials!
      path = Rails.root.join("config/rails_agents_credentials.yml")
      return unless path.exist?

      data = YAML.safe_load(path.read) || {}
      RailsAgents.configure do |config|
        config.api_key = data["api_key"] if data["api_key"].present?
        config.project_id = data["project_id"] if data["project_id"].present?
        config.api_base = data["api_base"] if data["api_base"].present?
        config.dashboard_base = data["dashboard_base"] if data["dashboard_base"].present?
      end
    rescue Psych::SyntaxError
      nil
    end

    def build_embed_url(path)
      base = RailsAgents.config.dashboard_base.to_s.chomp("/")
      url = "#{base}#{path}"
      query = { embed: "1" }
      query[:token] = @embed_token if @embed_token.present?
      "#{url}?#{query.to_query}"
    end
  end
end
