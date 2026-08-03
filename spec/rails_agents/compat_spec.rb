# frozen_string_literal: true

require "spec_helper"
require "rails_agents/compat"

RSpec.describe RailsAgents::Compat do
  describe ".redirect_options" do
    it "includes allow_other_host on Rails 7+" do
      allow(described_class).to receive(:at_least?).with(7, 0).and_return(true)
      expect(described_class.redirect_options).to eq(allow_other_host: true)
    end

    it "is empty on Rails 6.1" do
      allow(described_class).to receive(:at_least?).with(7, 0).and_return(false)
      expect(described_class.redirect_options).to eq({})
    end
  end

  describe ".application_name" do
    it "returns a string" do
      expect(described_class.application_name).to be_a(String)
    end
  end
end
