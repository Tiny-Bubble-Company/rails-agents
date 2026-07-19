# frozen_string_literal: true

require "yaml"

module RailsAgents
  module CredentialsWriter
    module_function

    def write!(api_key:, project_id: nil)
      path = Rails.root.join("config/rails_agents_credentials.yml")
      payload = {
        "api_key" => api_key,
        "project_id" => project_id
      }.compact
      File.write(path, payload.to_yaml)

      env_path = Rails.root.join(".env")
      lines = {
        "RAILS_AGENTS_API_KEY" => api_key,
        "RAILS_AGENTS_PROJECT_ID" => project_id
      }.compact

      if env_path.exist?
        existing = File.read(env_path)
        lines.each do |key, value|
          if existing.match?(/^#{Regexp.escape(key)}=/)
            existing = existing.gsub(/^#{Regexp.escape(key)}=.*$/, "#{key}=#{value}")
          else
            existing = existing.sub(/\n*\z/, "\n") + "#{key}=#{value}\n"
          end
        end
        File.write(env_path, existing)
      else
        File.write(env_path, lines.map { |k, v| "#{k}=#{v}" }.join("\n") + "\n")
      end
    end
  end
end
