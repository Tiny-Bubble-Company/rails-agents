# frozen_string_literal: true

module RailsAgents
  class SessionsController < ApplicationController
    def new
      cloud_redirect("/signin")
    end

    def destroy
      cloud_redirect("/signout")
    end
  end
end
