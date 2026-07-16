# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module RailsAgents
  # Sidekiq-style dashboard at /agents — signup, agents list, links into Cloud.
  class DashboardController < WebController
    def index
      return if ingest_query_credentials!

      return render :connect unless connected?

      load_dashboard!
    rescue Cloud::CloudError => error
      @error = error.message
      @agents = []
      @balance = nil
    end

    def create_account
      payload = {
        fullName: params.require(:full_name).to_s.strip,
        email: params.require(:email).to_s.strip,
        companyName: params[:company_name].to_s.strip,
        companyWebsite: params[:company_website].to_s.strip
      }

      result = signup_on_cloud!(payload)
      store_credentials!(
        api_key: result.fetch("api_key"),
        app_id: result.fetch("app_id"),
        bridge_secret: result.fetch("bridge_secret")
      )
      flash[:notice] = "Account created. Copy the keys into ENV so Tool Bridge and CLI keep working after restart."
      flash[:rails_agents_credentials] = result.slice("api_key", "app_id", "bridge_secret")
      redirect_to root_path
    rescue ActionController::ParameterMissing => error
      flash[:alert] = error.message
      redirect_to root_path
    rescue => error
      flash[:alert] = "Signup failed: #{error.message}"
      redirect_to root_path
    end

    def connect
      key = params.require(:api_key).to_s.strip
      abort_unless_key!(key)
      store_credentials!(
        api_key: key,
        app_id: params[:app_id].to_s.strip.presence || RailsAgents.config.app_id,
        bridge_secret: params[:bridge_secret].to_s.strip.presence || RailsAgents.config.tool_bridge_secret
      )
      flash[:notice] = "Connected to Rails Agents Cloud."
      redirect_to root_path
    rescue ActionController::ParameterMissing, ArgumentError => error
      flash[:alert] = error.message
      redirect_to root_path
    end

    def disconnect
      session.delete(:rails_agents_api_key)
      session.delete(:rails_agents_app_id)
      session.delete(:rails_agents_bridge_secret)
      flash[:notice] = "Disconnected this browser session. ENV keys are unchanged."
      redirect_to root_path
    end

    def show
      return redirect_to root_path unless connected?

      @agent_id = params[:id]
      @agent = cloud_client.agent_status(@agent_id)
      @runs = cloud_client.agent_runs(@agent_id)
    rescue Cloud::CloudError => error
      flash[:alert] = error.message
      redirect_to root_path
    end

    private

    # @return [Boolean] true when a redirect was issued
    def ingest_query_credentials!
      key = params[:key].to_s
      return false unless key.start_with?("rak_")

      store_credentials!(
        api_key: key,
        app_id: params[:app].to_s.presence,
        bridge_secret: params[:bridge].to_s.presence
      )
      flash[:notice] = "Connected from Cloud signup. Add the keys to ENV for production."
      flash[:rails_agents_credentials] = {
        "api_key" => key,
        "app_id" => params[:app],
        "bridge_secret" => params[:bridge]
      }
      redirect_to root_path
      true
    end

    def load_dashboard!
      data = cloud_client.list_agents
      @agents = data["agents"] || data[:agents] || []
      balance = cloud_client.billing_balance
      @balance = balance["credit_usd"] || balance["credit_cents"]
      @subscription = balance["subscription_status"]
      @credentials = flash[:rails_agents_credentials]
    end

    def abort_unless_key!(key)
      raise ArgumentError, "API key must start with rak_" unless key.start_with?("rak_")
    end

    def signup_on_cloud!(payload)
      uri = URI.join("#{dashboard_url}/", "api/signup")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = JSON.generate(payload)
      res = http.request(req)
      body = JSON.parse(res.body.to_s)
      unless res.is_a?(Net::HTTPSuccess)
        raise body["error"] || "Cloud signup returned #{res.code}"
      end

      {
        "api_key" => body["api_key"] || body["apiKey"],
        "app_id" => body["app_id"] || body["appId"],
        "bridge_secret" => body["bridge_secret"] || body["bridgeSecret"]
      }.tap do |creds|
        raise "Cloud signup missing api_key" if creds["api_key"].to_s.empty?
      end
    end
  end
end
