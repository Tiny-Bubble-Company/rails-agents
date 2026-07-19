# frozen_string_literal: true

require "fileutils"
require "pathname"

module RailsAgents
  # Pulls agent files from Rails Agent Cloud and writes them under app/agents/<slug>/.
  class LocalSync
    class Error < StandardError; end

    def initialize(client: Client.new, root: nil)
      @client = client
      @root = Pathname.new(root || (defined?(Rails) ? Rails.root : Dir.pwd))
    end

    # agent_id: cloud agent id (agt_…) or slug/name accepted by the API
    def pull!(agent_id)
      raise Error, "Not connected — run handshake or set RAILS_AGENTS_API_KEY" unless RailsAgents.config.configured?

      agent = fetch_agent(agent_id)
      slug = present(agent["slug"]) || slugify(agent["name"]) || slugify(agent_id)
      raise Error, "Could not resolve agent slug for #{agent_id}" unless present(slug)

      files_payload = @client.list_files(agent: agent["id"] || agent_id)
      files = normalize_files_list(files_payload)
      written = []
      deleted = []

      agent_dir = @root.join("app/agents", slug)
      FileUtils.mkdir_p(agent_dir)

      files.each do |file|
        rel = normalize_relative_path(file["path"] || file[:path], slug)
        abs = @root.join(rel)
        ensure_inside_agents!(abs, slug)

        content = file["content"] || file[:content]
        if content.nil?
          next
        end

        FileUtils.mkdir_p(abs.dirname)
        File.write(abs, content)
        written << rel.to_s
      end

      {
        "ok" => true,
        "agent_id" => agent["id"] || agent_id,
        "slug" => slug,
        "written" => written,
        "deleted" => deleted,
        "count" => written.size
      }
    end

    private

    def fetch_agent(agent_id)
      response = @client.get_agent(agent: agent_id)
      data = response.is_a?(Hash) ? (response["data"] || response) : {}
      data = data["agent"] if data.is_a?(Hash) && data["agent"].is_a?(Hash)
      raise Error, "Agent not found: #{agent_id}" unless data.is_a?(Hash) && present(data["id"] || data["slug"] || data["name"])

      data
    end

    def normalize_files_list(payload)
      return [] if payload.nil?

      if payload.is_a?(Array)
        payload
      elsif payload.is_a?(Hash)
        payload["data"] || payload["files"] || []
      else
        []
      end
    end

    def normalize_relative_path(path, slug)
      raw = path.to_s.sub(%r{\A/+}, "")
      raise Error, "Invalid path" if raw.empty? || raw.include?("..")

      if raw.start_with?("app/agents/")
        raw
      elsif raw.start_with?("#{slug}/")
        "app/agents/#{raw}"
      else
        "app/agents/#{slug}/#{raw}"
      end
    end

    def ensure_inside_agents!(abs_path, slug)
      agents_root = @root.join("app/agents", slug).expand_path
      expanded = abs_path.expand_path
      return if expanded.to_s.start_with?(agents_root.to_s + File::SEPARATOR) || expanded == agents_root

      raise Error, "Refusing to write outside app/agents/#{slug}: #{abs_path}"
    end

    def present(value)
      str = value.to_s.strip
      str.empty? ? nil : str
    end

    def slugify(value)
      present(value.to_s.downcase.gsub(/[^a-z0-9]+/, "_").gsub(/\A_|_\z/, ""))
    end
  end
end
