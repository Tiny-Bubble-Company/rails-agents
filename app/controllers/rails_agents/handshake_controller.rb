# frozen_string_literal: true

require "yaml"

module RailsAgents
  class HandshakeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create

    def create
      api_key_param = params[:api_key].to_s.strip.presence

      if api_key_param
        write_credentials!(api_key: api_key_param, project_id: params[:project_id].presence)
        apply_runtime_config!(api_key: api_key_param, project_id: params[:project_id].presence)
        redirect_to rails_agents.root_path, notice: "Connected with API key."
        return
      end

      email = params.require(:email).to_s.strip
      password = params.require(:password).to_s
      workspace = params[:workspace].presence || (defined?(Rails) ? Rails.application.class.module_parent_name : "App")

      response = Client.new.handshake(
        email: email,
        password: password,
        workspace: workspace
      )
      data = response["data"] || response
      api_key = data["api_key"] || data.dig("apiKey", "token")
      project_id = data["project_id"] || data.dig("project", "id")
      embed_token = data["embed_token"]

      raise Client::Error.new("No API key returned") if api_key.blank?

      write_credentials!(api_key: api_key, project_id: project_id)
      apply_runtime_config!(api_key: api_key, project_id: project_id)

      redirect_to rails_agents.dashboard_path(embed_token: embed_token),
                  notice: "Connected to Rails Agent Cloud."
    rescue Client::Error => e
      flash[:alert] = e.message
      redirect_to rails_agents.root_path
    rescue ActionController::ParameterMissing => e
      flash[:alert] = e.message
      redirect_to rails_agents.root_path
    end

    private

    def write_credentials!(api_key:, project_id:)
      path = Rails.root.join("config/rails_agents_credentials.yml")
      payload = {
        "api_key" => api_key,
        "project_id" => project_id,
        "api_base" => RailsAgents::Configuration::DEFAULT_ORIGIN,
        "dashboard_base" => RailsAgents::Configuration::DEFAULT_ORIGIN
      }.compact
      File.write(path, payload.to_yaml)

      env_path = Rails.root.join(".env")
      lines = [
        "RAILS_AGENTS_API_KEY=#{api_key}",
        ("RAILS_AGENTS_PROJECT_ID=#{project_id}" if project_id),
        "RAILS_AGENTS_API_BASE=#{RailsAgents::Configuration::DEFAULT_ORIGIN}",
        "RAILS_AGENTS_DASHBOARD_BASE=#{RailsAgents::Configuration::DEFAULT_ORIGIN}"
      ].compact
      if env_path.exist?
        existing = File.read(env_path)
        unless existing.include?("RAILS_AGENTS_API_KEY=")
          File.open(env_path, "a") { |f| f.puts; f.puts lines.join("\n") }
        end
      end
    end

    def apply_runtime_config!(api_key:, project_id:)
      RailsAgents.configure do |config|
        config.api_key = api_key
        config.project_id = project_id if project_id
        config.api_base = RailsAgents::Configuration::DEFAULT_ORIGIN
        config.dashboard_base = RailsAgents::Configuration::DEFAULT_ORIGIN
      end
    end
  end
end
