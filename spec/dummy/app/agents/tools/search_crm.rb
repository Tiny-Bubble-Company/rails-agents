# frozen_string_literal: true

class SearchCrm < RailsAgents::Tool
  description "Search CRM contacts by name or company"
  param :query, :string

  def call(query:)
    records = [
      {name: "Jane Doe", company: "Acme Corp", email: "jane@acme.com", plan: "pro"},
      {name: "Bob Smith", company: "Globex", email: "bob@globex.com", plan: "starter"}
    ]
    records.select { |r| r.values.any? { |v| v.to_s.downcase.include?(query.downcase) } }
  end
end
