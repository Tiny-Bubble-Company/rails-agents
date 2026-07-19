# frozen_string_literal: true

module RailsAgents
  # Async / scheduled agents (digests, cron, Sidekiq / Solid Queue jobs).
  # Trigger from a job or rake task with +YourAgent.run(message)+.
  class BackgroundAgent < Base
    def self.agent_kind
      :background
    end
  end
end
