# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Agent generator templates" do
  templates_root = File.expand_path("../../lib/generators/rails_agents/agent/templates", __dir__)

  it "default agent template uses BYOK model DSL and taxonomy base class" do
    content = File.read(File.join(templates_root, "agent.rb.tt"))
    expect(content).to include("<%= agent_base_class %>")
    expect(content).to include("credential: :company_openai")
    expect(content).not_to include("model :auto")
  end

  it "database template scaffolds taxonomy base + sql_query (and optional mongo_query)" do
    content = File.read(File.join(templates_root, "agent_database.rb.tt"), encoding: "UTF-8")
    expect(content).to include("<%= agent_base_class %>")
    expect(content).to include("tool :sql_query")
    expect(content).to include("include_mongo_query?")
    expect(content).not_to match(/^\s*tool :lookup_order/m)
    expect(content).not_to match(/^\s*tool :search_products/m)
  end

  it "database prompt documents support triage workflow and BYOK" do
    content = File.read(File.join(templates_root, "prompt_database.md.tt"))
    expect(content).to include("Customer Support Agent")
    expect(content).to include("Ask followup questions if anything unclear")
    expect(content).to include("sql_query")
    expect(content).to include("BYOK")
  end

  it "scaffolds an explicit workspace Library imports manifest" do
    content = File.read(File.join(templates_root, "imports.yml.tt"))

    expect(content).to include("imports: []")
    expect(content).to include("shared/skills/triage.rb")
  end
end
