# frozen_string_literal: true

require "yaml"

module RailsAgents
  class HandshakeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create

    def create
      email = params.require(:email).to_s.strip
      password = params.require(:password).to_s
      workspace = params[:workspace].presence || Rails.application.class.module_parent_name

      response = Client.new.handshake(
        email: email,
        password: password,
        workspace: workspace
      )
      data = response["data"] || response
      api_key = data["api_key"]
      project_id = data["project_id"]
      embed_token = data["embed_token"]

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
      }
      File.write(path, payload.to_yaml)

      env_path = Rails.root.join(".env")
      lines = [
        "RAILS_AGENTS_API_KEY=#{api_key}",
        "RAILS_AGENTS_PROJECT_ID=#{project_id}",
        "RAILS_AGENTS_API_BASE=#{RailsAgents::Configuration::DEFAULT_ORIGIN}",
        "RAILS_AGENTS_DASHBOARD_BASE=#{RailsAgents::Configuration::DEFAULT_ORIGIN}"
      ]
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
        config.project_id = project_id
        config.api_base = RailsAgents::Configuration::DEFAULT_ORIGIN
        config.dashboard_base = RailsAgents::Configuration::DEFAULT_ORIGIN
      end
    end
  end
end
