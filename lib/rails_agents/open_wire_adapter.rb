# frozen_string_literal: true

require "open_wire"

module RailsAgents
  # Open-Wire channel adapter — thin wrapper so agents don't talk HTTP directly.
  module OpenWireAdapter
    module_function

    def client(base_url: nil, api_key: nil)
      ::OpenWire::Client.new(base_url: base_url, api_key: api_key)
    end

    def verify_inbound!(secret:, body:, headers:)
      ::OpenWire::Webhook.verify_and_parse!(
        secret: secret,
        body: body,
        headers: headers
      )
    end

    def reply!(installation_id:, to:, text:, thread_id: nil, client: nil)
      (client || self.client).send_message(
        installation_id: installation_id,
        to: to,
        text: text,
        thread_id: thread_id
      )
    end
  end
end
