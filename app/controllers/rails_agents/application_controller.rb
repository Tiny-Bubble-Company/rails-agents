# frozen_string_literal: true

module RailsAgents
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout "rails_agents/application"

    helper_method :dashboard_url, :configured?

    private

    def configured?
      RailsAgents.config.configured?
    end

    def dashboard_url(path = "/dashboard")
      base = RailsAgents.config.dashboard_base
      "#{base.chomp("/")}#{path}"
    end

    def cloud_redirect(path)
      redirect_to dashboard_url(path), allow_other_host: true
    end
  end
end
