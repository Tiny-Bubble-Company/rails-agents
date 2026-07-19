# frozen_string_literal: true

require "yaml"

module RailsAgents
  class PullsController < ApplicationController
    # JSON pull from the /agents parent page (postMessage bridge).
    def create
      load_local_credentials!

      unless RailsAgents.config.configured?
        return render json: { ok: false, error: "Not connected to Rails Agent Cloud" }, status: :unprocessable_entity
      end

      agent_id = params[:agent_id].presence || params[:agent].presence || params.dig(:pull, :agent_id)
      if agent_id.blank?
        return render json: { ok: false, error: "agent_id is required" }, status: :bad_request
      end

      result = LocalSync.new.pull!(agent_id)
      render json: result
    rescue LocalSync::Error, Client::Error => e
      render json: { ok: false, error: e.message }, status: :unprocessable_entity
    end

    private

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
  end
end
