# frozen_string_literal: true

module RailsAgents
  class SessionsController < ApplicationController
    include LocalAuth

    before_action :redirect_if_configured!, only: %i[new create verify]

    def new
      @step = :email
      @github_url = github_oauth_url
    end

    def create
      @github_url = github_oauth_url
      @email = params[:email].to_s.strip.downcase

      if @email.blank?
        flash.now[:alert] = "Email is required."
        @step = :email
        render :new, status: :unprocessable_entity
        return
      end

      response = Client.new.email_start(email: @email, purpose: "signin")
      session[:ra_auth] = {
        "purpose" => "signin",
        "email" => @email,
        "dev_code" => response["devCode"] || response["dev_code"]
      }
      @step = :code
      @dev_code = session[:ra_auth]["dev_code"]
      render :new
    rescue Client::Error => e
      flash.now[:alert] = e.message
      @step = :email
      render :new, status: :unprocessable_entity
    end

    def verify
      pending = session[:ra_auth] || {}
      @email = pending["email"].to_s
      @github_url = github_oauth_url
      code = params[:code].to_s.strip

      if @email.blank? || code.blank?
        flash.now[:alert] = "Enter the code we emailed you."
        @step = :code
        render :new, status: :unprocessable_entity
        return
      end

      response = Client.new.email_verify(email: @email, code: code)
      session.delete(:ra_auth)
      complete_cloud_auth!(response)
    rescue Client::Error => e
      flash.now[:alert] = e.message
      @step = :code
      @dev_code = pending["dev_code"]
      render :new, status: :unprocessable_entity
    end

    def destroy
      cloud = RailsAgents.config.dashboard_base.to_s.chomp("/")
      cloud = "https://cloud.rails-agent.com" if cloud.blank?
      redirect_to "#{cloud}/signin", allow_other_host: true
    end
  end
end
