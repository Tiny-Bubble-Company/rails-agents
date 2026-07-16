# frozen_string_literal: true

require "pathname"

module RailsAgents
  # Minimal .env reader/writer so `rails-agents deploy` can persist Cloud keys
  # without the developer editing credentials by hand.
  module EnvFile
    KEYS = %w[
      RAILS_AGENTS_API_KEY
      RAILS_AGENTS_APP_ID
      RAILS_AGENTS_BRIDGE_SECRET
    ].freeze

    module_function

    def path_for(root)
      Pathname(root).join(".env")
    end

    # Load keys into ENV when missing (does not override existing ENV).
    def load!(root)
      path = path_for(root)
      return {} unless path.file?

      parsed = parse(path.read.to_s.force_encoding("UTF-8"))
      parsed.each do |key, value|
        next if ENV.key?(key) && ENV[key].to_s != ""

        ENV[key] = value
      end
      parsed
    end

    def write_credentials!(root, api_key:, app_id:, bridge_secret:)
      path = path_for(root)
      existing = path.file? ? path.read : ""
      lines = existing.lines.map(&:chomp)

      updates = {
        "RAILS_AGENTS_API_KEY" => api_key.to_s,
        "RAILS_AGENTS_APP_ID" => app_id.to_s,
        "RAILS_AGENTS_BRIDGE_SECRET" => bridge_secret.to_s
      }

      updates.each do |key, value|
        next if value.empty?

        replaced = false
        lines.map! do |line|
          if line.match?(/\A#{Regexp.escape(key)}=/)
            replaced = true
            "#{key}=#{value}"
          else
            line
          end
        end
        lines << "#{key}=#{value}" unless replaced
      end

      unless existing.include?("RAILS_AGENTS") || lines.any? { |l| l.start_with?("# Rails Agents") }
        lines.unshift("# Rails Agents - written by rails-agents deploy")
      end

      path.write((lines.join("\n") + "\n").encode("UTF-8"))
      updates
    end

    def parse(contents)
      contents.each_line.with_object({}) do |line, acc|
        line = line.strip
        next if line.empty? || line.start_with?("#")
        next unless line.include?("=")

        key, value = line.split("=", 2)
        key = key.to_s.strip
        value = value.to_s.strip.gsub(/\A['"]|['"]\z/, "")
        acc[key] = value if KEYS.include?(key) || key.start_with?("RAILS_AGENTS_")
      end
    end
  end
end
