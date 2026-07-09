# frozen_string_literal: true

require "spec_helper"
require "webmock/rspec"

RSpec.describe RailsAgents::Providers::OpenRouter do
  it "calls the OpenRouter API" do
    stub_request(:post, "https://openrouter.ai/api/v1/chat/completions").to_return(
      status: 200,
      body: {
        choices: [{message: {content: "ok"}, finish_reason: "stop"}],
        usage: {prompt_tokens: 3, completion_tokens: 2}
      }.to_json
    )

    response = described_class.new(api_key: "test").chat(
      messages: [RailsAgents::Message.user("hi")],
      client_tools: [],
      model: "meta-llama/llama-3.3-70b-instruct:free"
    )

    expect(response.content).to eq("ok")
  end
end
