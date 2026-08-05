# frozen_string_literal: true

module RailsAgents
  class RegistrationsController < ApplicationController
    include LocalAuth

    before_action :redirect_if_configured!

    def new
      @github_url = github_oauth_url
      if params[:change_email].present?
        session.delete(:ra_auth)
      end
      pending = session[:ra_auth]
      if pending.is_a?(Hash) && pending["email"].present? && pending["purpose"] == "signup"
        @step = :code
        @email = pending["email"]
        @name = pending["name"]
        @workspace = pending["workspace"].presence || default_workspace
        @dev_code = pending["dev_code"]
      else
        @step = :email
        @workspace = default_workspace
        @email = nil
        @name = nil
        @dev_code = nil
      end
    end

    def create
      @github_url = github_oauth_url
      @workspace = params[:workspace].to_s.strip.presence || default_workspace
      @name = params[:name].to_s.strip
      @email = params[:email].to_s.strip.downcase

      if @email.blank?
        flash.now[:alert] = "Email is required."
        @step = :email
        render :new, status: :unprocessable_entity
        return
      end

      response = Client.new.email_start(
        email: @email,
        purpose: "signup",
        name: @name.presence,
        company: @workspace
      )
      session[:ra_auth] = {
        "purpose" => "signup",
        "email" => @email,
        "name" => @name,
        "workspace" => @workspace,
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
      @name = pending["name"].to_s
      @workspace = pending["workspace"].to_s
      @github_url = github_oauth_url
      code = params[:code].to_s.strip

      if @email.blank? || code.blank?
        flash.now[:alert] = "Enter the code we emailed you."
        @step = :code
        render :new, status: :unprocessable_entity
        return
      end

      response = Client.new.email_verify(
        email: @email,
        code: code,
        name: @name.presence,
        company: @workspace.presence
      )
      session.delete(:ra_auth)
      complete_cloud_auth!(response)
    rescue Client::Error => e
      flash.now[:alert] = e.message
      @step = :code
      @dev_code = pending["dev_code"]
      @github_url = github_oauth_url
      render :new, status: :unprocessable_entity
    end

    private

    def default_workspace
      RailsAgents::Compat.application_name
    rescue StandardError
      "MyApp"
    end
  end
end
