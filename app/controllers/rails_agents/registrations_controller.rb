# frozen_string_literal: true

module RailsAgents
  class RegistrationsController < ApplicationController
    def new
      cloud_redirect("/signup")
    end
  end
end
