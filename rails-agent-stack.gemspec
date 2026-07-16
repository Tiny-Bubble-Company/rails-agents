# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name = "rails-agent-stack"
  spec.version = RailsAgents::VERSION
  spec.authors = ["Tiny Bubble Company"]
  spec.email = ["hello@tinybubble.company"]

  spec.summary = "Dead-simple AI agents for Rails — cloud by default, speed to production"
  spec.description = <<~DESC.gsub(/\s+/, " ").strip
    Rails Agents (gem: rails-agent-stack) is the simplest way to add production
    AI agents to Ruby on Rails. Define an agent in Ruby, attach your app code as
    tools via Tool Bridge, call .run — durable sessions and sandboxes run on
    Rails Agents Cloud (Eve on shared Vercel infra). Free to sign up and build;
    prepaid Credits (or BYOK) before hosted runs; promote to production when ready.

    Built for developers searching for Rails AI agents, Ruby LLM agents,
    OpenAI / Anthropic / Claude / GPT tool-calling, agentic workflows, and a
    simpler alternative to RubyLLM or LangChain when you want zero infra.

    One mental model: RailsAgents::Agent. Fastest path to a production agent
    with the least code.
  DESC

  spec.homepage = "https://tiny-bubble-company.github.io/rails-agents/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2"

  spec.metadata = {
    "homepage_uri" => spec.homepage,
    "source_code_uri" => "https://github.com/Tiny-Bubble-Company/rails-agents",
    "changelog_uri" => "https://github.com/Tiny-Bubble-Company/rails-agents/blob/main/CHANGELOG.md",
    "documentation_uri" => "https://tiny-bubble-company.github.io/rails-agents/",
    "bug_tracker_uri" => "https://github.com/Tiny-Bubble-Company/rails-agents/issues",
    "rubygems_mfa_required" => "true",
  }

  spec.files = Dir.chdir(__dir__) do
    Dir["{app,config,lib}/**/*", "README.md", "CHANGELOG.md", "ARCHITECTURE.md", "TENANCY.md", "DECISIONS.md", "MIT-LICENSE", "rails-agent-stack.gemspec"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.9", "< 3"
  spec.add_dependency "rails", ">= 7.1", "< 9"
  spec.add_dependency "zeitwerk", ">= 2.6", "< 3"
end
