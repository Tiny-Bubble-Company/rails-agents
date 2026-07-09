# frozen_string_literal: true

class SheetBuilderAgent < RailsAgents::Agent
  provider :anthropic
  model "claude-sonnet-4-20250514"
  description "Create simple Excel spreadsheets from a short brief."
  skills :xlsx
end
