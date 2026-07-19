# frozen_string_literal: true

module RailsAgents
  class SchemaController < ApplicationController
    # GET /agents/schema — table list for Knowledge → Rails database connector
    def show
      tables = ActiveRecord::Base.connection.tables
        .reject { |t| t.start_with?("ar_", "solid_", "schema_migrations", "rails_agents") }
        .sort
        .map do |name|
          cols =
            begin
              ActiveRecord::Base.connection.columns(name).map(&:name)
            rescue StandardError
              []
            end
          { name: name, columns: cols.first(40) }
        end

      render json: { ok: true, tables: tables, adapter: ActiveRecord::Base.connection.adapter_name }
    rescue StandardError => e
      render json: { ok: false, error: e.message, tables: [] }, status: :unprocessable_entity
    end
  end
end
