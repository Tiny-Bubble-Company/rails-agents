# frozen_string_literal: true

class LeadQualifier < RailsAgents::Agent
  provider :openai
  model "gpt-4o-mini"
  description "Qualifies inbound leads, answers basic questions, and creates a CRM note when a lead looks promising."
  tools "SearchCrm", "CreateCrmNote"
end
