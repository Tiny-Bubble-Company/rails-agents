# frozen_string_literal: true

require_relative "lib/rails_agents/version"

Gem::Specification.new do |spec|
  spec.name          = "rails-agent-stack"
  spec.version       = RailsAgents::VERSION
  spec.authors       = ["Tiny Bubble Company"]
  spec.email         = ["support@rails-agent.com"]

  spec.summary       = "Full-stack agentic platform for Ruby on Rails — build, test, deploy, " \
                         "and monitor production AI agents (RubyLLM / ActiveAgent alternative)."
  # Blank lines between paragraphs are intentional — RubyGems renders them on the gem page.
  spec.description   = <<~DESC
    Rails Agent is a single, beautiful full-stack agentic platform for Ruby on Rails. Build chatbots, knowledge (RAG-style) agents, workflow agents, operations jobs, monitoring agents, and every agentic workflow you can think of — as files in app/agents/, with a mounted /agents dashboard and hosted cloud runtime.

    Build: instructions (prompt.md), tools (function calling over ActiveRecord), connectors (OAuth SaaS), channels (Slack, Teams via Open-Wire, web, cron, HTTP API), skills, packages (Skills.sh / APM / Smithery), knowledge, memory (Mem0), guardrails, playbooks, and a shared agents library.

    Test: cloud sandbox runs, streaming, evals (golden cases), traces, and cost before you ship.

    Deploy: rails-agents sync → deploy to the production harness, BYOK credentials, and channel go-live — without provisioning agent infra yourself.

    Monitor: runs, traces, evals, budgets, and usage in /agents.

    BYOK providers: OpenAI, Anthropic, Google Gemini, OpenRouter, xAI, Groq, Mistral AI, DeepSeek, Together AI, Fireworks AI, Perplexity, Cerebras, Hugging Face, and custom OpenAI-compatible providers. Reference keys as credential: :company_openai in Ruby — secrets never live in Git.

    Rails 6.1+, Ruby 3.2+. Alternative to RubyLLM and ActiveAgent when you need the whole agent lifecycle, not just an LLM client.
  DESC
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
