# frozen_string_literal: true

require "spec_helper"

RSpec.describe RailsAgents::Tool do
  class AddNumbers < RailsAgents::Tool
    description "Adds two numbers"
    param :a, :number
    param :b, :number

    def call(a:, b:) = a + b
  end

  it "builds a provider-ready definition" do
    expect(AddNumbers.definition[:name]).to eq("add_numbers")
    expect(AddNumbers.new.call(a: 2, b: 3)).to eq(5)
  end
end

RSpec.describe RailsAgents::ToolSet do
  class EchoTool < RailsAgents::Tool
    description "Echoes input"
    param :text, :string
    def call(text:) = text
  end

  it "executes tools by name" do
    set = RailsAgents::ToolSet.use(EchoTool)
    expect(set.execute("echo", {"text" => "hi"})).to eq("hi")
  end

  it "resolves tools declared as strings" do
    set = RailsAgents::ToolSet.new("EchoTool")
    expect(set.execute("echo", {"text" => "hi"})).to eq("hi")
  end
end
