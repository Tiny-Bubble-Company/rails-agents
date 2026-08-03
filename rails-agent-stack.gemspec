# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-agent-stack"
  spec.version       = RailsAgents::VERSION
  spec.authors       = ["Tiny Bubble Company"]
  spec.email         = ["support@rails-agent.com"]

  spec.summary       = "Rails AI agents framework — fullstack Ruby on Rails agents " \
                         "(ActiveAgent / RubyLLM alternative)."
  spec.description   = "Rails Agent is the most advanced agentic platform for Ruby on Rails. " \
                         "Mount /agents, scaffold agent directories, attach BYOK model credentials, " \
                         "and build with instructions, tools, connectors, channels, skills, packages, " \
                         "knowledge, memory, and guardrails. Sync, run, deploy, and monitor on " \
                         "Rails Agent Cloud — a production Rails agent framework and better " \
                         "alternative to RubyLLM and ActiveAgent for fullstack Rails AI agents."
  spec.homepage      = "https://rails-agent.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://rails-agent.com/docs/getting-started"
  spec.metadata["source_code_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents"
  spec.metadata["bug_tracker_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents/issues"
  spec.metadata["changelog_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents/releases"
  spec.metadata["rubygems_mimetype"] = "application/x-rubygem"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f == "Gemfile.lock" || f.start_with?("spec/fixtures/")
    end
  rescue StandardError
    Dir["{app,config,exe,lib,docs}/**/*", "exe/*", "*.{md,gemspec,rake}", "MIT-LICENSE", "AGENTS.md"]
  end

  spec.bindir        = "exe"
  spec.executables   = ["rails-agents"]
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 6.1"
  spec.add_dependency "thor", "~> 1.3"
  spec.add_dependency "open-wire", "~> 0.1"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "webmock", "~> 3.23"
end
