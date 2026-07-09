# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe RailsAgents::Providers::OpenAI do
  it "normalizes chat responses" do
    stub_request(:post, "https://api.openai.com/v1/chat/completions").to_return(
      status: 200,
      body: {
        choices: [{message: {content: "ok"}, finish_reason: "stop"}],
        usage: {prompt_tokens: 3, completion_tokens: 2}
      }.to_json
    )

    response = described_class.new(api_key: "test").chat(
      messages: [RailsAgents::Message.user("hi")],
      client_tools: [],
      model: "gpt-4o-mini"
    )

    expect(response.content).to eq("ok")
    expect(response.usage.total).to eq(5)
  end
end
