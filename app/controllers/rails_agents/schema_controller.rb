# frozen_string_literal: true

module RailsAgents
  class SchemaController < ApplicationController
    # GET /agents/schema — table list for Knowledge → Rails database connector
    def show
      databases = configured_databases
      tables = active_record_tables
      tables.concat(mongoid_collections) if tables.empty? || databases.any? { |db| db[:adapter] == "mongoid" }
      primary = databases.find { |db| db[:name] == "primary" } || databases.first

      render json: {
        ok: true,
        tables: tables,
        adapter: primary&.dig(:adapter),
        databases: databases,
        config_files: detected_config_files
      }
    rescue StandardError => e
      render json: { ok: false, error: e.message, tables: [] }, status: :unprocessable_entity
    end

    private

    def configured_databases
      configs = []
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.configurations.configs_for(env_name: Rails.env).each do |db|
          configs << {
            name: db.name.to_s,
            adapter: normalize_adapter(db.adapter),
            raw_adapter: db.adapter.to_s,
            source: "config/database.yml"
          }
        end
      end
      if Rails.root.join("config/mongoid.yml").exist?
        configs << {
          name: "mongoid",
          adapter: "mongoid",
          raw_adapter: "mongodb",
          source: "config/mongoid.yml"
        }
      end
      configs.uniq { |db| [db[:name], db[:adapter], db[:source]] }
    rescue StandardError
      []
    end

    def active_record_tables
      return [] unless defined?(ActiveRecord::Base)

      ActiveRecord::Base.connection.tables
        .reject { |table| internal_table?(table) }
        .sort
        .map do |name|
          columns =
            begin
              ActiveRecord::Base.connection.columns(name).map(&:name)
            rescue StandardError
              []
            end
          {
            name: name,
            columns: columns.first(40),
            kind: "table",
            samples: sample_rows(name, columns)
          }
        end
    rescue StandardError
      []
    end

    def sample_rows(_table, columns)
      return [] if columns.blank?

      quoted = ActiveRecord::Base.connection.quote_table_name(_table)
      rows = ActiveRecord::Base.connection.exec_query("SELECT * FROM #{quoted} LIMIT 8").to_a
      rows.map do |row|
        row.transform_values { |value| truncate_sample(value) }
      end
    rescue StandardError
      []
    end

    def truncate_sample(value)
      text = value.is_a?(String) ? value : value.inspect
      text.length > 120 ? "#{text[0, 117]}..." : text
    end

    def mongoid_collections
      return [] unless defined?(Mongoid) && Mongoid.respond_to?(:default_client)

      Mongoid.default_client.database.collection_names
        .reject { |name| name.start_with?("system.") }
        .sort
        .map { |name| { name: name, columns: [], kind: "collection", samples: [] } }
    rescue StandardError
      []
    end

    def detected_config_files
      %w[config/database.yml config/mongoid.yml]
        .select { |path| Rails.root.join(path).exist? }
    end

    def normalize_adapter(adapter)
      value = adapter.to_s.downcase
      return "postgresql" if value.include?("postgres") || value.include?("postgis") || value.include?("cockroach")
      return "mysql" if value.include?("mysql") || value.include?("trilogy") || value.include?("maria")
      return "sqlite" if value.include?("sqlite")
      return "sqlserver" if value.include?("sqlserver")
      return "oracle" if value.include?("oracle")

      value.presence || "active_record"
    end

    def internal_table?(table)
      table.start_with?("ar_", "solid_", "rails_agents") ||
        %w[schema_migrations ar_internal_metadata].include?(table)
    end
  end
end
