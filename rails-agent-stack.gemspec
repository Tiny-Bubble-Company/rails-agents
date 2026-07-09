# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name = "rails-agent-stack"
  spec.version = RailsAgents::VERSION
  spec.authors = ["Tiny Bubble Company"]
  spec.email = ["hello@tinybubble.company"]

  spec.summary = "Dead-simple AI agents for Rails — speed to production, not framework noise"
  spec.description = <<~DESC.gsub(/\s+/, " ").strip
    Rails Agents (gem: rails-agent-stack) is the simplest way to build AI agents
    in Ruby on Rails. Define an LLM agent as a plain Ruby class, attach your app
    code as tools, add skills like web search or spreadsheets, and call .run —
    minutes to production, not days of framework setup.

    Built for developers searching for Rails AI agents, Ruby LLM agents,
    OpenAI / Anthropic / Claude / GPT tool-calling agents, OpenRouter and
    Grok (xAI) integrations, agentic workflows, RAG helpers, and a lighter
    alternative to RubyLLM, LangChain, or rolling your own multi-turn tool loop.

    One mental model: RailsAgents::Agent. No dashboards, no cloud lock-in,
    no agent lifecycle UI — just provider, model, description, tools, and skills.
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
    Dir["{app,lib}/**/*", "README.md", "CHANGELOG.md", "MIT-LICENSE", "rails-agent-stack.gemspec"]
  end

  spec.require_paths = ["lib"]

  spec.add_dependency "faraday", ">= 2.9", "< 3"
  spec.add_dependency "rails", ">= 7.1", "< 9"
  spec.add_dependency "zeitwerk", ">= 2.6", "< 3"
end
