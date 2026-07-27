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

  it "database template scaffolds KnowledgeAgent with order and product tools" do
    content = File.read(File.join(templates_root, "agent_database.rb.tt"))
    expect(content).to include("KnowledgeAgent")
    expect(content).to include("lookup_order")
    expect(content).to include("search_products")
    expect(content).to include("Order.find_by")
    expect(content).to include("Product.where")
  end

  it "database prompt documents demo orders and BYOK" do
    content = File.read(File.join(templates_root, "prompt_database.md.tt"))
    expect(content).to include("ORD-DEMO-1001")
    expect(content).to include("BYOK")
  end
end
