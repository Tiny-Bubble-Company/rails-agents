# frozen_string_literal: true

require "yaml"

module RailsAgents
  class ConnectController < ApplicationController
    # GET /agents/connect?code=… — finishes cloud signup/signin for this Rails app.
    def show
      code = params[:code].to_s.strip
      if code.blank?
        redirect_to rails_agents.root_path, alert: "Missing connect code. Sign up or sign in again."
        return
      end

      response = Client.new.claim_connect(code)
      data = response["data"] || response
      api_key = data["apiKey"] || data["api_key"]
      project_id = data["projectId"] || data["project_id"]
      embed_token = data["embedToken"] || data["embed_token"]

      raise Client::Error.new("No API key returned") if api_key.blank?

      CredentialsWriter.write!(api_key: api_key, project_id: project_id)
      RailsAgents.configure do |config|
        config.api_key = api_key
        config.project_id = project_id if project_id
      end

      redirect_to rails_agents.dashboard_path(embed_token: embed_token),
                  notice: "Connected to Rails Agent Cloud."
    rescue Client::Error => e
      flash[:alert] = e.message
      redirect_to rails_agents.root_path
    end
  end
end
