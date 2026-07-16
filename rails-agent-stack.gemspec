# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name = "rails-agent-stack"
  spec.version = RailsAgents::VERSION
  spec.authors = ["Tiny Bubble Company"]
  spec.email = ["hello@tinybubble.company"]

  spec.summary = "Durable agents for Rails — your agent is a directory"
  spec.description = <<~DESC.gsub(/\s+/, " ").strip
    Rails Agents (gem: rails-agent-stack) is the production agent framework for
    Ruby on Rails — like Eve for Rails apps. An app/agents/<name>/instructions.md
    file is a complete agent; add schedules, tools, and skills as it grows.
    CLI: rails-agents new | test | deploy. Runs on Rails Agents Cloud with durable
    execution (checkpointed steps, park between turns, resume on delivery), hosted
    cron, Tool Bridge into your Rails models/jobs, and a dashboard with run logs —
    without Render rake+cron glue or managing Node/Workflow yourself.
    Built for durable Rails AI agents, tool-calling workflows, and a simpler path
    than RubyLLM or LangChain when you want production agents, not a full multimodal
    AI toolkit. Prepaid Credits before hosted runs.
    Docs + entry point: https://rails.meerkatagents.com
  DESC

  spec.homepage = "https://rails.meerkatagents.com"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri" => "https://rails.meerkatagents.com",
    "source_code_uri" => "https://rails.meerkatagents.com",
    "changelog_uri" => "https://rails.meerkatagents.com/guide/changelog",
    "documentation_uri" => "https://rails.meerkatagents.com",
    "bug_tracker_uri" => "https://rails.meerkatagents.com",
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,config,exe,lib}/**/*", "README.md", "CHANGELOG.md", "ARCHITECTURE.md", "TENANCY.md", "DECISIONS.md", "PRICING.md", "MIT-LICENSE", "rails-agent-stack.gemspec"]
  end

  spec.bindir = "exe"
  spec.executables = ["rails-agents"]
  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.9", "< 3"
  spec.add_dependency "rails", ">= 7.1", "< 9"
  spec.add_dependency "zeitwerk", ">= 2.6", "< 3"
end
