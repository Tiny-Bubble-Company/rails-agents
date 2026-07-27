# frozen_string_literal: true

module RailsAgents
  # Watches runs, traces, evals, and alerts on anomalies or SLA breaches.
  class MonitoringAgent < Base
    def self.agent_kind
      :monitoring
    end
  end
end
