# frozen_string_literal: true

class Support < RailsAgents::KnowledgeAgent
  model :gpt_5_mini, provider: :openai, credential: :company_openai
  memory :conversation
  knowledge_from "knowledge/**/*"

  tool :lookup_order do |order_id:|
    { id: order_id, status: "shipped", note: "Example only — wire to your Order model." }
  end

  skill :triage, from: "skills/triage.rb"
  channel :slack
end
