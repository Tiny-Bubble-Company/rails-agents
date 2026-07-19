# frozen_string_literal: true

require "thor"
require "io/console"

module RailsAgents
  class CLI < Thor
    package_name "rails-agents"

    desc "install", "Mount the engine and write the initializer"
    def install
      exec_rails_generator("rails_agents:install")
    end

    desc "new NAME", "Scaffold a new agent directory"
    def new(name)
      exec_rails_generator("rails_agents:agent", name)
    end

    desc "login", "Sign in to Rails Agent Cloud and print export lines for your API key"
    method_option :email, type: :string, aliases: "-e"
    method_option :workspace, type: :string, aliases: "-w"
    def login
      email = options[:email] || ask("Email:")
      password = $stdin.tty? ? $stdin.getpass("Password: ") : ask("Password:")
      workspace = options[:workspace]

      response = Client.new.handshake(
        email: email,
        password: password,
        workspace: workspace
      )
      data = response["data"] || response
      exports = data["exports"] || {
        "RAILS_AGENTS_API_KEY" => data["api_key"],
        "RAILS_AGENTS_PROJECT_ID" => data["project_id"],
        "RAILS_AGENTS_API_BASE" => "https://cloud.rails-agent.com",
        "RAILS_AGENTS_DASHBOARD_BASE" => "https://cloud.rails-agent.com"
      }

      say ""
      say "Signed in to #{data.dig("tenant", "name") || "Rails Agent Cloud"}."
      say "Add these to your shell or .env:"
      say ""
      exports.each do |key, value|
        say "export #{key}=#{value}"
      end
      say ""
      say "Then visit /agents in your Rails app."
      if data["dashboard_url"]
        say "Dashboard: #{data["dashboard_url"].split("?").first}"
      end
    rescue Client::Error => e
      say_error e.message
      exit 1
    end

    map "run" => :execute

    desc "execute NAME [MESSAGE]", "Run an agent against the cloud runtime"
    method_option :session, type: :string, desc: "Session ID for conversation memory"
    def execute(name, message = nil)
      agent_class = load_agent_class(name)
      message ||= $stdin.tty? ? Thor::Shell::Basic.new.ask("Message:") : $stdin.read

      result = agent_class.run(message, session_id: options[:session])
      say result.output
    rescue LoadError, NameError => e
      say_error "Could not load agent #{name}: #{e.message}"
      exit 1
    rescue Client::Error => e
      say_error e.message
      exit 1
    end

    desc "deploy [NAME]", "Deploy agent bundle(s) to Rails Agent Cloud"
    def deploy(name = nil)
      agents = name ? [name] : discover_agent_names
      agents.each do |agent_name|
        agent_class = load_agent_class(agent_name)
        response = agent_class.deploy
        say "Deployed #{agent_name}: #{response["id"] || response["status"] || "ok"}"
      end
    rescue Client::Error => e
      say_error e.message
      exit 1
    end

    desc "sync NAME", "Push local agent files to the cloud"
    def sync(name)
      agent_class = load_agent_class(name)
      dir = agent_class.agent_directory
      root = defined?(Rails) ? Rails.root.to_s : Dir.pwd
      files = Dir[File.join(dir, "**", "*")].select { |p| File.file?(p) }.map do |path|
        rel = path.sub(%r{\A#{Regexp.escape(root)}/?}, "")
        rel = rel.sub(%r{\A.*?app/agents/}, "app/agents/") if rel.include?("app/agents/")
        { "path" => rel, "content" => File.read(path) }
      end

      Client.new.sync_files(agent: name, files: files)
      say "Synced #{files.size} files for #{name}"
    rescue Client::Error => e
      say_error e.message
      exit 1
    end

    desc "pull AGENT_ID_OR_SLUG", "Pull agent files from the cloud into app/agents/<slug>/"
    def pull(agent_id)
      result = LocalSync.new.pull!(agent_id)
      say "Pulled #{result["count"]} files into app/agents/#{result["slug"]}/"
      Array(result["written"]).each { |path| say "  #{path}" }
    rescue LocalSync::Error, Client::Error => e
      say_error e.message
      exit 1
    end

    desc "logs [NAME]", "Fetch recent run logs from the cloud"
    method_option :limit, type: :numeric, default: 50
    def logs(name = nil)
      print_json Client.new.logs(agent: name, limit: options[:limit])
    end

    desc "traces [NAME]", "Fetch recent traces from the cloud"
    method_option :limit, type: :numeric, default: 50
    def traces(name = nil)
      print_json Client.new.traces(agent: name, limit: options[:limit])
    end

    desc "evals [NAME]", "Fetch eval results from the cloud"
    def evals(name = nil)
      print_json Client.new.evals(agent: name)
    end

    default_task :help

    private

    def exec_rails_generator(generator, *args)
      if File.exist?("bin/rails")
        exec "bin/rails", "generate", generator, *args
      else
        say_error "Run this command from your Rails app root (bin/rails not found)."
        exit 1
      end
    end

    def load_agent_class(name)
      path = Rails.root.join("app/agents/#{name}/agent.rb") if defined?(Rails)
      path ||= File.expand_path("app/agents/#{name}/agent.rb", Dir.pwd)

      require path
      classify(name).constantize
    end

    def discover_agent_names
      base = defined?(Rails) ? Rails.root.join("app/agents") : Pathname.new(Dir.pwd).join("app/agents")
      return [] unless base.directory?

      base.children.select(&:directory?).map { |d| d.basename.to_s }
    end

    def classify(name)
      name.to_s.split(%r{[_\-/]}).map(&:capitalize).join
    end

    def print_json(data)
      require "json"
      say JSON.pretty_generate(data)
    end

    def say_error(message)
      say message, :red
    end
  end
end
