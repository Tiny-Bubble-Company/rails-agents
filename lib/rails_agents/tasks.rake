# frozen_string_literal: true

namespace :rails_agents do
  desc "Install Rails Agents (alias for rails g rails_agents:install)"
  task install: :environment do
    sh "bin/rails generate rails_agents:install"
  end
end
