# frozen_string_literal: true

require "json"
require "net/http"
require "uri"

module RailsAgents
  class Client
    class Error < StandardError
      attr_reader :status, :body

      def initialize(message, status: nil, body: nil)
        super(message)
        @status = status
        @body = body
      end
    end

    def initialize(config: RailsAgents.config)
      @config = config
    end

    def create_run(agent:, message:, session_id: nil, metadata: {})
      post("/runs", {
        agent: agent,
        message: message,
        session_id: session_id,
        project_id: @config.project_id,
        metadata: metadata
      }.compact)
    end

    def stream_run(run_id, &block)
      get_stream("/runs/#{run_id}/stream", &block)
    end

    def deploy(agent:, bundle_path: nil)
      payload = { agent: agent, project_id: @config.project_id }
      payload[:bundle_path] = bundle_path if bundle_path
      post("/deploys", payload)
    end

    def install_channel(kind:, redirect_url: nil)
      post("/channels/#{kind}/install", {
        project_id: @config.project_id,
        redirect_url: redirect_url
      }.compact)
    end

    def sync_knowledge(agent:, paths: [])
      post("/knowledge/sync", {
        agent: agent,
        project_id: @config.project_id,
        paths: paths
      })
    end

    def get_agent(agent:)
      get("/agents/#{agent}")
    end

    def sync_files(agent:, files:)
      put("/agents/#{agent}/files", { files: files })
    end

    def list_files(agent:)
      get("/agents/#{agent}/files")
    end

    def handshake(email:, password:, workspace: nil)
      post("/auth/handshake", {
        email: email,
        password: password,
        workspace: workspace
      }.compact, auth: false)
    end

    def claim_connect(code)
      post("/auth/connect/claim", { code: code }, auth: false)
    end

    def email_start(email:, purpose:, name: nil, company: nil)
      post("/auth/email/start", {
        email: email,
        purpose: purpose,
        name: name,
        company: company
      }.compact, auth: false)
    end

    def email_verify(email:, code:, name: nil, company: nil)
      post("/auth/email/verify", {
        email: email,
        code: code,
        name: name,
        company: company
      }.compact, auth: false)
    end

    def logs(agent: nil, limit: 50)
      get("/logs", query: { agent: agent, limit: limit, project_id: @config.project_id }.compact)
    end

    def traces(agent: nil, limit: 50)
      get("/traces", query: { agent: agent, limit: limit, project_id: @config.project_id }.compact)
    end

    def evals(agent: nil)
      get("/evals", query: { agent: agent, project_id: @config.project_id }.compact)
    end

    private

    def get(path, query: {})
      request(:get, path, query: query)
    end

    def post(path, body, auth: true)
      request(:post, path, body: body, auth: auth)
    end

    def put(path, body, auth: true)
      request(:put, path, body: body, auth: auth)
    end

    def request(method, path, body: nil, query: {}, auth: true)
      uri = build_uri(path, query)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.open_timeout = 10
      http.read_timeout = 120

      request_class =
        case method
        when :get then Net::HTTP::Get
        when :put then Net::HTTP::Put
        else Net::HTTP::Post
        end

      req = request_class.new(uri)
      req["Accept"] = "application/json"
      req["Content-Type"] = "application/json"
      req["Authorization"] = "Bearer #{@config.api_key}" if auth && @config.api_key
      req.body = JSON.generate(body) if body

      response = http.request(req)
      parse_response(response)
    end

    def get_stream(path, &block)
      uri = build_uri(path)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      http.read_timeout = nil

      req = Net::HTTP::Get.new(uri)
      req["Accept"] = "text/event-stream"
      req["Authorization"] = "Bearer #{@config.api_key}" if @config.api_key

      http.request(req) do |response|
        raise Error.new("Stream failed", status: response.code.to_i, body: response.body) unless response.is_a?(Net::HTTPOK)

        buffer = +""
        response.read_body do |chunk|
          buffer << chunk
          while (line = buffer.slice!(/.*\n/))
            line = line.strip
            next if line.empty? || line.start_with?(":")

            if line.start_with?("data: ")
              data = line.delete_prefix("data: ")
              block.call(JSON.parse(data)) if block
            end
          end
        end
      end
    end

    def build_uri(path, query = {})
      base = @config.api_v1_base
      base = "#{base}/" unless base.end_with?("/")
      uri = URI.join(base, path.delete_prefix("/"))
      uri.query = URI.encode_www_form(query) unless query.empty?
      uri
    end

    def parse_response(response)
      body = response.body.to_s
      parsed = body.empty? ? {} : JSON.parse(body)

      return parsed if response.is_a?(Net::HTTPSuccess)

      message = parsed.is_a?(Hash) ? (parsed["error"] || parsed["message"] || "Request failed") : "Request failed"
      raise Error.new(message, status: response.code.to_i, body: parsed)
    rescue JSON::ParserError
      raise Error.new("Invalid JSON response", status: response.code.to_i, body: body) unless response.is_a?(Net::HTTPSuccess)

      {}
    end
  end
end
