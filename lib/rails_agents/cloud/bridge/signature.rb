# frozen_string_literal: true

require "openssl"

module RailsAgents
  module Cloud
    module Bridge
      module Signature
        module_function

        def sign(secret:, timestamp:, body:)
          digest = OpenSSL::HMAC.hexdigest("SHA256", secret, "#{timestamp}.#{body}")
          "v1=#{digest}"
        end

        def verify!(secret:, timestamp:, body:, signature:, skew: 300)
          raise ConfigurationError, "tool_bridge_secret is not configured" if secret.to_s.empty?

          ts = Integer(timestamp)
          raise Cloud::CloudError, "bridge timestamp skew" if (Time.now.to_i - ts).abs > skew

          expected = sign(secret: secret, timestamp: timestamp, body: body)
          unless secure_compare(expected, signature.to_s)
            raise Cloud::CloudError, "invalid bridge signature"
          end

          true
        end

        def secure_compare(a, b)
          return false unless a.bytesize == b.bytesize

          OpenSSL.fixed_length_secure_compare(a, b)
        end
      end
    end
  end
end
