# frozen_string_literal: true

require "rails_agents"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
