# frozen_string_literal: true

class WebResearchAgent < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Research topics using current web information. Cite sources when possible."
  skills :web_search, max_uses: 3
end
