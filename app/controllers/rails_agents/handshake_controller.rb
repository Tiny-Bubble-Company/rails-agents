# frozen_string_literal: true

module RailsAgents
  class HandshakeController < ApplicationController
    skip_before_action :verify_authenticity_token, only: :create

    def create
      api_key_param = params[:api_key].to_s.strip.presence

      if api_key_param
        CredentialsWriter.write!(api_key: api_key_param, project_id: params[:project_id].presence)
        apply_runtime_config!(api_key: api_key_param, project_id: params[:project_id].presence)
        redirect_to rails_agents.root_path, notice: "Connected with API key."
        return
      end

      email = params.require(:email).to_s.strip
      password = params.require(:password).to_s
      workspace = params[:workspace].presence || (defined?(Rails) ? RailsAgents::Compat.application_name : "App")

      response = Client.new.handshake(
        email: email,
        password: password,
        workspace: workspace
      )
      data = response["data"] || response
      api_key = data["api_key"] || data.dig("apiKey", "token") || data["apiKey"]
      project_id = data["project_id"] || data.dig("project", "id") || data["projectId"]
      embed_token = data["embed_token"] || data["embedToken"]

      raise Client::Error.new("No API key returned") if api_key.blank?

      CredentialsWriter.write!(api_key: api_key, project_id: project_id)
      apply_runtime_config!(api_key: api_key, project_id: project_id)

      session[:ra_embed_token] = embed_token if embed_token.present?
      redirect_to rails_agents.dashboard_path, notice: "Connected to Rails Agent Cloud."
    rescue Client::Error => e
      flash[:alert] = e.message
      redirect_to rails_agents.root_path
    rescue ActionController::ParameterMissing => e
      flash[:alert] = e.message
      redirect_to rails_agents.root_path
    end

    private

    def apply_runtime_config!(api_key:, project_id:)
      RailsAgents.configure do |config|
        config.api_key = api_key
        config.project_id = project_id if project_id
      end
    end
  end
end
