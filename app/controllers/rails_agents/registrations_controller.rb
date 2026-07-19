# frozen_string_literal: true

module RailsAgents
  class RegistrationsController < ApplicationController
    include LocalAuth

    before_action :redirect_if_configured!

    def new
      @step = :email
      @github_url = github_oauth_url
      @workspace = default_workspace
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
      (Rails.application.class.module_parent_name rescue "MyApp")
    end
  end
end
