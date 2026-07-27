# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-agent-stack"
  spec.version       = RailsAgents::VERSION
  spec.authors       = ["Rails Agent Team"]
  spec.email         = ["hello@railsagents.dev"]

  spec.summary       = "Fullstack AI agents for Rails — build in code, deploy from /agents."
  spec.description   = "Mount /agents, scaffold agent directories, BYOK model credentials, " \
                         "and test/deploy/monitor on Rails Agent Cloud. Documentation-first onboarding."
  spec.homepage      = "https://rails-agent.com"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.2.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["documentation_uri"] = "https://rails-agent.com/docs/getting-started"
  spec.metadata["source_code_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents"
  spec.metadata["bug_tracker_uri"] = "https://github.com/Tiny-Bubble-Company/rails-agents/issues"
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

  spec.add_dependency "railties", ">= 7.0"
  spec.add_dependency "thor", "~> 1.3"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "webmock", "~> 3.23"
end
