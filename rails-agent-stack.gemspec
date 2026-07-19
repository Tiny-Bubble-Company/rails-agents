# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-agent-stack"
  spec.version       = RailsAgents::VERSION
  spec.authors       = ["Rails Agent Team"]
  spec.email         = ["hello@railsagents.dev"]

  spec.summary       = "Fullstack AI agents for Rails — mount /agents, vibe-code, deploy."
  spec.description   = "The fullstack agentic platform for Rails. One gem install, chat in the " \
                         "dashboard, and we handle code, infra and deploys. Zero AI knowledge required."
  spec.homepage      = "https://meerkatagents.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://meerkatagents.com/docs/getting-started"
  spec.metadata["source_code_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents"
  spec.metadata["bug_tracker_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents/issues"
  spec.metadata["rubygems_mimetype"] = "application/x-rubygem"

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      f == "Gemfile.lock" || f.start_with?("spec/fixtures/")
    end
  rescue StandardError
    Dir["{app,config,exe,lib,docs}/**/*", "exe/*", "*.{md,gemspec,rake}", "MIT-LICENSE"]
  end

  spec.bindir        = "exe"
  spec.executables   = ["rails-agents"]
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "thor", "~> 1.3"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "webmock", "~> 3.23"
end
