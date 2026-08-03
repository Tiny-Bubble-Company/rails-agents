# frozen_string_literal: true

require "rails_agents/version"
require "rails_agents/compat"
require "rails_agents/configuration"
require "rails_agents/client"
require "rails_agents/credentials_writer"
require "rails_agents/local_auth"
require "rails_agents/local_sync"
require "rails_agents/library_imports"
require "rails_agents/base"
require "rails_agents/knowledge_agent"
require "rails_agents/creation_agent"
require "rails_agents/workflow_agent"
require "rails_agents/operations_agent"
require "rails_agents/monitoring_agent"
require "rails_agents/chat_agent"
require "rails_agents/background_agent"
require "rails_agents/cli"

begin
  require "open_wire"
  require "rails_agents/open_wire_adapter"
rescue LoadError
  # open-wire gem optional until path/RubyGems dependency is installed
end

if defined?(Rails::Engine)
  require "rails_agents/engine"
end

if defined?(Rails::Railtie)
  require "rails_agents/railtie"
end

module RailsAgents
  TAXONOMY_TYPES = %i[knowledge workflow operations monitoring].freeze
  LEGACY_TAXONOMY_TYPES = %i[creation].freeze

  class << self
    attr_writer :config

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end

    def reset!
      @config = Configuration.new
    end
  end
end

# PRD uses RailsAgent - alias to RailsAgents for compatibility
RailsAgent = RailsAgents unless defined?(RailsAgent)
