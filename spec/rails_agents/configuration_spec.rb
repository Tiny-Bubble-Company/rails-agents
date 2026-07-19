# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAgents::Configuration do
  subject(:config) { described_class.new }

  it "defaults api_base to cloud.rails-agent.com" do
    expect(config.api_base).to eq("https://cloud.rails-agent.com")
  end

  it "defaults dashboard_base to cloud.rails-agent.com" do
    expect(config.dashboard_base).to eq("https://cloud.rails-agent.com")
  end

  it "builds api_v1_base under /api/v1" do
    expect(config.api_v1_base).to eq("https://cloud.rails-agent.com/api/v1")
  end

  it "reads api_key from ENV" do
    with_env("RAILS_AGENTS_API_KEY" => "test-key") do
      expect(described_class.new.api_key).to eq("test-key")
    end
  end

  it "reads project_id from ENV" do
    with_env("RAILS_AGENTS_PROJECT_ID" => "prj_test") do
      expect(described_class.new.project_id).to eq("prj_test")
    end
  end

  it "ignores RAILS_AGENTS_API_BASE env (cloud host is fixed)" do
    with_env("RAILS_AGENTS_API_BASE" => "https://example.invalid") do
      expect(described_class.new.api_base).to eq("https://cloud.rails-agent.com")
    end
  end

  it "reports configured when api_key is present" do
    config.api_key = "abc"
    expect(config).to be_configured
  end

  it "reports not configured when api_key is blank" do
    config.api_key = ""
    expect(config).not_to be_configured
  end

  def with_env(vars)
    old = vars.keys.to_h { |k| [k, ENV[k]] }
    vars.each { |k, v| ENV[k] = v }
    yield
  ensure
    old.each { |k, v| v.nil? ? ENV.delete(k) : ENV[k] = v }
  end
end
