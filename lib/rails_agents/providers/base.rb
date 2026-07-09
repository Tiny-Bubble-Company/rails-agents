# frozen_string_literal: true

module RailsAgents
  module Providers
    class Base
    def chat(messages:, tools: [], client_tools: tools, skills: nil, model:, json: false, &block)
      raise NotImplementedError
    end
    end

    def self.build(name, api_key: nil)
      kwargs = api_key.nil? ? {} : {api_key: api_key}

      case name.to_sym
      when :openai then OpenAI.new(**kwargs)
      when :anthropic then Anthropic.new(**kwargs)
      when :openrouter then OpenRouter.new(**kwargs)
      when :grok then Grok.new(**kwargs)
      else raise ConfigurationError, "Unknown provider: #{name}. Use: #{Configuration::PROVIDERS.join(', ')}"
      end
    end
  end
end
