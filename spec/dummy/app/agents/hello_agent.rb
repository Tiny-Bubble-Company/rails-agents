# frozen_string_literal: true

class HelloAgent < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Reply in one friendly sentence."
end
