# frozen_string_literal: true

module RailsAgents
  class PaymentRequired < Error
    attr_reader :checkout_url

    def initialize(message = "Sandbox trial ended. Subscribe to continue.", checkout_url: nil)
      super(message)
      @checkout_url = checkout_url
    end
  end
end
