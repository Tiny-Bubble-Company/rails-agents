# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require "uri"
require "net/http"

module RailsAgents
  # Developer CLI - the only commands you need:
  #
  #   rails-agents new weather
  #   rails-agents test weather
  #   rails-agents deploy weather   # signup -> .env -> Cloud -> opens /agents
  #
  class CLI
    CLOUD_DASHBOARD = ENV.fetch("RAILS_AGENTS_DASHBOARD", "https://agents.meerkatagents.com")

    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
      @signup_flags = extract_signup_flags!(argv)
      command = argv.shift
      case command
      when "new", "generate", "g"
        cmd_new(argv.shift)
      when "test"
        cmd_test(argv.shift, live: argv.include?("--live"))
      when "deploy"
        cmd_deploy(argv.shift)
      when "status"
        cmd_status(argv.shift)
      when "help", "-h", "--help", nil
        print_help
      else
        warn "Unknown command: #{command}"
        print_help
        exit 1
      end
    end

    private

    def extract_signup_flags!(argv)
      flags = {}
      argv.reject! do |arg|
        case arg
        when /\A--email=(.+)\z/ then flags[:email] = $1; true
        when /\A--name=(.+)\z/ then flags[:full_name] = $1; true
        when /\A--company=(.+)\z/ then flags[:company_name] = $1; true
        when /\A--website=(.+)\z/ then flags[:company_website] = $1; true
        else false
        end
      end
      flags
    end

    def cmd_new(name)
      abort "Usage: rails-agents new <agent_name>" if name.to_s.strip.empty?

      id = snake_case(name)
      root = agents_root.join(id)
      abort "Already exists: #{root}" if root.exist?

      FileUtils.mkdir_p(root.join("schedules"))
      FileUtils.mkdir_p(root.join("tools"))
      FileUtils.mkdir_p(root.join("skills"))

      File.write(root.join("instructions.md"), instructions_template(id))
      File.write(root.join("agent.json"), JSON.pretty_generate({
        "model" => "anthropic/claude-sonnet-4",
        "name" => id,
        "triggers" => ["schedule"]
      }))
      File.write(root.join("schedules/morning.yml"), <<~YAML)
        # when it acts on its own - hosted cron after deploy
        cron: "0 7 * * *"
        timezone: UTC
        message: |
          Fetch today's weather for configured cities and post a short morning brief.
          Keep it practical: conditions, high/low, and any notable alerts.
      YAML

      write_weather_scaffold!(root) if id == "weather"
      write_generic_scaffold!(root, id) unless id == "weather"

      say "OK Created app/agents/#{id}/  (complete agent)"
      say ""
      say "  agent.json            # the model it runs on"
      say "  instructions.md       # who it is"
      say "  tools/                # what it can do"
      say "  skills/               # what it knows"
      say "  schedules/            # when it acts on its own"
      say ""
      say "  Next: rails-agents deploy #{id}"
    end

    def write_weather_scaffold!(root)
      File.write(root.join("tools/fetch_forecast.rb"), <<~RUBY)
        # frozen_string_literal: true

        class FetchForecast < RailsAgents::Tool
          description "Fetch current or daily forecast for a city"
          param :city, :string, description: "City name"
          def call(city:)
            {city: city, summary: "Implement FetchForecast in your app"}
          end
        end
      RUBY
      File.write(root.join("tools/post_summary.rb"), <<~RUBY)
        # frozen_string_literal: true

        class PostSummary < RailsAgents::Tool
          description "Post the weather brief (Slack, email, DB, ...)"
          param :body, :string, description: "Short markdown brief"
          def call(body:)
            {ok: true, preview: body.to_s[0, 120]}
          end
        end
      RUBY
      File.write(root.join("skills/cities-and-units.md"), <<~MD)
        # cities-and-units - what it knows

        Default cities: Berlin, London, New York.
        Prefer Celsius unless the user asks for Fahrenheit.
        Keep briefs short: city, conditions, high/low.
      MD
    end

    def write_generic_scaffold!(root, id)
      File.write(root.join("tools/example_tool.rb"), <<~RUBY)
        # frozen_string_literal: true

        class ExampleTool < RailsAgents::Tool
          description "Example tool for the #{id} agent"
          param :input, :string, required: false, description: "Optional input"
          def call(input: nil)
            {ok: true, input: input}
          end
        end
      RUBY
      File.write(root.join("skills/domain.md"), <<~MD)
        # domain - what it knows

        Add domain vocabulary, policies, and examples for `#{id}` here.
      MD
    end

    def cmd_test(name, live: false)
      agent = load_agent!(name)
      say "Validating #{agent.id}..."
      say "  instructions.md  OK (#{agent.instructions.bytesize} bytes)"
      say "  model            #{agent.model}"

      schedule = Dir.glob(agent.root.join("schedules/*.{yml,yaml}").to_s).first
      if schedule
        say "  schedule         OK #{Pathname(schedule).relative_path_from(rails_root)}"
      else
        say "  schedule         - (optional)"
      end

      say ""
      say "Local validation passed."
      if live
        ensure_cloud_credentials!
        say "Running against Cloud sandbox (--live)..."
        result = agent.run(
          "Local test: describe the steps you would take for a morning weather brief for Berlin. Do not call external systems."
        )
        if result.respond_to?(:success) && result.success
          say "OK Cloud sandbox OK"
          say result.output.to_s
        else
          abort "Cloud test failed: #{result.respond_to?(:error) ? result.error : result.inspect}"
        end
      else
        say "Deploy when ready: rails-agents deploy #{agent.id}"
      end
    end

    def cmd_deploy(name)
      agent = load_agent!(name)
      creds = ensure_cloud_credentials!

      say "Deploying #{agent.id} -> Rails Agents Cloud..."
      client = Cloud::Client.new

      begin
        client.sync_agent(agent.id, agent.manifest.merge(
          "schedule" => read_schedule(agent),
          "environment" => "production"
        ))
      rescue PaymentRequired => error
        open_billing!(error)
        abort "Add Credits / subscribe, then re-run: rails-agents deploy #{agent.id}"
      end

      body = {"status" => "synced"}
      begin
        body = client.deploy_agent(agent.id)
      rescue PaymentRequired => error
        say "Agent synced. Subscribe to mark production deploy (Credits / billing)."
        say error.message
        open_billing!(error)
      rescue Cloud::CloudError => error
        if error.message.include?("subscription_required") || error.message.include?("402")
          say "Agent synced. Subscribe when ready for production deploy."
          open_url!("#{CLOUD_DASHBOARD}/dashboard/billing?subscribe=1")
        else
          raise
        end
      end

      agents_url = local_agents_url(creds)
      say "OK #{agent.id} ready"
      say "  status: #{body["status"] || "synced"}"
      say "  dashboard: #{agents_url}"
      say "  Agents list + details: /agents on your Rails app"
      open_url!(agents_url)
    end

    def cmd_status(name)
      ensure_cloud_credentials!
      agent_id = name || nil
      client = Cloud::Client.new
      if agent_id
        body = client.agent_status(agent_id)
        puts JSON.pretty_generate(body)
      else
        body = client.list_agents
        puts JSON.pretty_generate(body)
      end
    end

    def load_agent!(name)
      abort "Usage: rails-agents <command> <agent_name>" if name.to_s.strip.empty?
      id = snake_case(name)
      DirectoryAgent.new(id, root: agents_root.join(id))
    end

    def snake_case(value)
      value.to_s
        .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr("-", "_")
        .downcase
    end

    # Load .env -> signup if needed -> write .env -> apply config.
    # @return [Hash] credentials used for /agents handoff
    def ensure_cloud_credentials!
      EnvFile.load!(rails_root)
      refresh_config_from_env!

      if RailsAgents.config.api_key.to_s.start_with?("rak_")
        return {
          api_key: RailsAgents.config.api_key,
          app_id: RailsAgents.config.app_id,
          bridge_secret: RailsAgents.config.tool_bridge_secret
        }
      end

      say "First deploy - finish signup (creates your Rails Agents Cloud account)."
      say "Credentials are written to .env automatically - nothing else to configure."
      say ""

      creds = interactive_signup!
      EnvFile.write_credentials!(
        rails_root,
        api_key: creds[:api_key],
        app_id: creds[:app_id],
        bridge_secret: creds[:bridge_secret]
      )
      RailsAgents.config.apply_credentials!(**creds)
      say "OK Saved credentials to #{rails_root.join(".env")}"
      creds
    end

    def interactive_signup!
      full_name = pick_value((@signup_flags || {})[:full_name], ENV["RAILS_AGENTS_SIGNUP_NAME"]) || ask("Full name")
      email = pick_value((@signup_flags || {})[:email], ENV["RAILS_AGENTS_SIGNUP_EMAIL"]) || ask("Work email")
      company = pick_value((@signup_flags || {})[:company_name], ENV["RAILS_AGENTS_SIGNUP_COMPANY"]).to_s
      website = pick_value((@signup_flags || {})[:company_website], ENV["RAILS_AGENTS_SIGNUP_WEBSITE"]).to_s

      abort "Email is required for signup." if email.to_s.strip.empty?
      abort "Name is required for signup." if full_name.to_s.strip.empty?

      signup_on_cloud!(
        fullName: full_name.strip,
        email: email.strip,
        companyName: company.to_s.strip,
        companyWebsite: website.to_s.strip
      )
    end

    def ask(label)
      $stderr.print "#{label}: "
      $stderr.flush
      ($stdin.gets || "").to_s.strip
    end

    def pick_value(*values)
      values.each do |value|
        s = value.to_s.strip
        return s unless s.empty?
      end
      nil
    end

    def signup_on_cloud!(payload)
      uri = URI.join("#{CLOUD_DASHBOARD}/", "api/signup")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      req = Net::HTTP::Post.new(uri)
      req["Content-Type"] = "application/json"
      req["Accept"] = "application/json"
      req.body = JSON.generate(payload)
      res = http.request(req)
      body = JSON.parse(res.body.to_s)
      unless res.is_a?(Net::HTTPSuccess)
        raise "Cloud signup failed: #{body["error"] || res.code}"
      end

      {
        api_key: body["api_key"] || body["apiKey"],
        app_id: body["app_id"] || body["appId"],
        bridge_secret: body["bridge_secret"] || body["bridgeSecret"]
      }.tap do |creds|
        raise "Cloud signup missing api_key" if creds[:api_key].to_s.empty?
      end
    end

    def refresh_config_from_env!
      RailsAgents.config.api_key = ENV["RAILS_AGENTS_API_KEY"] if ENV["RAILS_AGENTS_API_KEY"]
      RailsAgents.config.app_id = ENV["RAILS_AGENTS_APP_ID"] if ENV["RAILS_AGENTS_APP_ID"]
      RailsAgents.config.tool_bridge_secret = ENV["RAILS_AGENTS_BRIDGE_SECRET"] if ENV["RAILS_AGENTS_BRIDGE_SECRET"]
    end

    def local_agents_url(creds)
      base = ENV.fetch("RAILS_AGENTS_APP_URL", RailsAgents.config.app_url.to_s)
      base = "http://127.0.0.1:3000" if base.to_s.empty?
      uri = URI.parse(base)
      uri.path = "/agents"
      if creds && creds[:api_key]
        uri.query = URI.encode_www_form(
          key: creds[:api_key],
          app: creds[:app_id],
          bridge: creds[:bridge_secret]
        )
      end
      uri.to_s
    end

    def open_billing!(error)
      url = error.checkout_url
      url = "#{CLOUD_DASHBOARD}#{url}" if url&.start_with?("/")
      url ||= "#{CLOUD_DASHBOARD}/dashboard/billing?subscribe=1"
      say error.message
      open_url!(url)
    end

    def open_url!(url)
      return if url.to_s.empty?
      say "-> #{url}"
      system("open", url) if RUBY_PLATFORM.include?("darwin")
    rescue StandardError
      nil
    end

    def read_schedule(agent)
      path = Dir.glob(agent.root.join("schedules/*.{yml,yaml}").to_s).min
      return nil unless path

      File.read(path)
    end

    def agents_root
      rails_root.join("app/agents")
    end

    def rails_root
      if defined?(::Rails) && ::Rails.respond_to?(:root) && ::Rails.root
        ::Rails.root
      else
        Pathname.pwd
      end
    end

    def instructions_template(id)
      <<~MD
        # Identity

        You are the `#{id}` agent for this Rails application.

        # Job

        Produce a short daily weather brief for configured cities.
        Fetch the forecast, summarize conditions in plain language, and post the result via Tool Bridge tools.

        # Rules

        1. Prefer Tool Bridge tools over guessing temperatures or conditions.
        2. Keep answers short and practical (city, conditions, high/low).
        3. Never invent API keys or secrets.
        4. If a forecast fetch fails, say so clearly and continue with other cities.
        5. Summarize: cities covered, failures if any.

        # Tools you may use

        - `FetchForecast` - current / daily forecast for a city
        - `PostSummary` - deliver the brief (Slack, email, DB, ...)

        # Output

        Return a short run report in Markdown.
      MD
    end

    def say(msg)
      puts msg
    end

    def print_help
      puts <<~HELP
        Rails Agents - directory in, deploy out

          rails-agents new <name>       Create app/agents/<name>/
          rails-agents test <name>      Validate the agent folder
          rails-agents deploy <name>    Signup (first time) -> .env -> Cloud -> open /agents
          rails-agents status [name]    Show agent status from Cloud

        Example:

          rails-agents new weather
          rails-agents deploy weather
          # opens http://127.0.0.1:3000/agents with your agents dashboard
      HELP
    end
  end
end
