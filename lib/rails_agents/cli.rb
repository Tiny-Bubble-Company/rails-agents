# frozen_string_literal: true

require "fileutils"
require "json"
require "pathname"
require "uri"
require "net/http"

module RailsAgents
  # Developer CLI — the only commands you need:
  #
  #   rails-agents new accidental_damage_sync
  #   rails-agents test accidental_damage_sync
  #   rails-agents deploy accidental_damage_sync
  #
  class CLI
    CLOUD_DASHBOARD = ENV.fetch("RAILS_AGENTS_DASHBOARD", "https://agents.meerkatagents.com")

    def self.start(argv)
      new.start(argv)
    end

    def start(argv)
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

    def cmd_new(name)
      abort "Usage: rails-agents new <agent_name>" if name.to_s.strip.empty?

      id = snake_case(name)
      root = agents_root.join(id)
      abort "Already exists: #{root}" if root.exist?

      FileUtils.mkdir_p(root.join("schedules"))
      FileUtils.mkdir_p(root.join("tools"))

      File.write(root.join("instructions.md"), instructions_template(id))
      File.write(root.join("agent.json"), JSON.pretty_generate({
        "model" => "anthropic/claude-sonnet-4",
        "name" => id,
        "triggers" => ["schedule"]
      }))
      File.write(root.join("schedules/poll.yml"), <<~YAML)
        # Hosted cron (Eve-shaped). Cloud runs this on your schedule.
        cron: "*/15 * * * *"
        timezone: UTC
        message: |
          Poll for new accidental damage cover agreements since the last run.
          For each new agreement, build the provider payload and upload via FTP.
          Log each agreement id as success or failure. Do not re-upload already synced ids.
      YAML
      File.write(root.join("tools/.keep"), "")

      say "✓ Created app/agents/#{id}/"
      say ""
      say "  1. Edit instructions.md (describe your sync rules)"
      say "  2. rails-agents test #{id}"
      say "  3. rails-agents deploy #{id}"
    end

    def cmd_test(name, live: false)
      agent = load_agent!(name)
      say "Validating #{agent.id}…"
      say "  instructions.md  ✓ (#{agent.instructions.bytesize} bytes)"
      say "  model            #{agent.model}"

      schedule = agent.root.join("schedules/poll.yml")
      if schedule.file?
        say "  schedule         ✓ #{schedule.relative_path_from(rails_root)}"
      else
        say "  schedule         — (optional)"
      end

      say ""
      say "Dry-run plan (local — no Cloud call):"
      say "  • Read new Accidental Damage Cover agreements from your Rails DB (via Tool Bridge)"
      say "  • Transform each into the insurer FTP payload"
      say "  • Upload to the provider FTP server"
      say "  • Record sync status so reruns are idempotent"
      say ""
      say "Preview instructions (first 280 chars):"
      preview = agent.instructions.to_s.encode("UTF-8", invalid: :replace, undef: :replace).strip
      say preview[0, 280].to_s
      say ""

      if live
        say "Running against Cloud sandbox (--live)…"
        result = agent.run(
          "Local test: describe the steps you would take for one new accidental damage cover agreement. Do not call external systems."
        )
        if result.respond_to?(:success) && result.success
          say "✓ Cloud sandbox OK"
          say result.output.to_s
        else
          abort "Cloud test failed: #{result.respond_to?(:error) ? result.error : result.inspect}"
        end
      else
        say "Local validation passed. Re-run with --live to hit Cloud sandbox:"
        say "  rails-agents test #{agent.id} --live"
      end
    end

    def cmd_deploy(name)
      agent = load_agent!(name)
      ensure_cloud_credentials!

      say "Deploying #{agent.id} → Rails Agents Cloud…"
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

      begin
        body = client.deploy_agent(agent.id)
      rescue PaymentRequired => error
        open_billing!(error)
        abort "Subscription required for production deploy. Finish checkout, then re-run deploy."
      rescue Cloud::CloudError => error
        if error.message.include?("subscription_required")
          open_url!("#{CLOUD_DASHBOARD}/dashboard/billing?subscribe=1")
          abort "Open the dashboard to create your account subscription, then re-run deploy."
        end
        raise
      end

      dashboard = body["dashboard_url"] || "#{CLOUD_DASHBOARD}/dashboard/agents/#{agent.id}"
      say "✓ Deployed #{agent.id}"
      say "  status: #{body["status"] || "deployed"}"
      say "  dashboard: #{dashboard}"
      open_url!(dashboard)
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

    def ensure_cloud_credentials!
      key = RailsAgents.config.api_key.to_s
      return unless key.empty?

      signup = "#{CLOUD_DASHBOARD}/signup?from=cli"
      say "No RAILS_AGENTS_API_KEY set."
      say "Opening signup — create account + subscription, then paste keys into .env:"
      say "  RAILS_AGENTS_API_KEY=rak_…"
      say "  RAILS_AGENTS_APP_ID=app_…"
      say "  RAILS_AGENTS_BRIDGE_SECRET=…"
      open_url!(signup)
      abort "Set credentials, then re-run the command."
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
      say "→ #{url}"
      system("open", url) if RUBY_PLATFORM.include?("darwin")
    rescue StandardError
      nil
    end

    def read_schedule(agent)
      path = agent.root.join("schedules/poll.yml")
      return nil unless path.file?

      path.read
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

        Monitor newly created agreements of type **Accidental Damage Cover**.
        For each new agreement, sync a payload file to the insurance provider FTP server.

        # Rules

        1. Only process agreements with type / product = Accidental Damage Cover.
        2. Never re-upload an agreement that already has a successful sync record.
        3. Use Tool Bridge tools for DB reads/writes and FTP upload (never invent credentials).
        4. On FTP failure, retry once, then mark the agreement failed with the error message.
        5. Summarize: processed count, uploaded count, failures.

        # Tools you may use

        - `ListNewAgreements` — agreements created since the watermark / last run
        - `BuildProviderPayload` — map agreement → insurer file format
        - `UploadFtp` — upload file to the provider FTP server
        - `MarkAgreementSynced` — persist success/failure + remote path

        # Output

        Return a short run report in Markdown.
      MD
    end

    def say(msg)
      puts msg
    end

    def print_help
      puts <<~HELP
        Rails Agents — simplest path from legacy Rails job → hosted agent

          rails-agents new <name>       Create app/agents/<name>/ (instructions + schedule)
          rails-agents test <name>      Validate locally (add --live for Cloud sandbox)
          rails-agents deploy <name>    Deploy to Cloud (signup/subscribe if needed)
          rails-agents status [name]    Show agent status / list from Cloud

        Example (Accidental Damage Cover → insurer FTP):

          rails-agents new accidental_damage_sync
          # edit app/agents/accidental_damage_sync/instructions.md
          rails-agents test accidental_damage_sync
          rails-agents deploy accidental_damage_sync
      HELP
    end
  end
end
