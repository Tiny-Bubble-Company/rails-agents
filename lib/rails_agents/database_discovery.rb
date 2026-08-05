# frozen_string_literal: true

require "pathname"
require "yaml"
require "fileutils"
require "erb"
require "time"
require "date"

module RailsAgents
  # Discovers SQL (ActiveRecord) and document (Mongoid) databases from the host
  # Rails app so install/agent generators and Tool Bridge know what to expose.
  class DatabaseDiscovery
    CONFIG_RELATIVE = "config/rails_agents_database.yml"

    Result = Struct.new(
      :active_record,
      :mongoid,
      :adapters,
      :config_files,
      :tables,
      :collections,
      :default_attach,
      keyword_init: true
    )

    class << self
      def config_path(root = nil)
        Pathname.new(root || default_root).join(CONFIG_RELATIVE)
      end

      def load(root = nil)
        path = config_path(root)
        return nil unless path.file?

        data = YAML.safe_load(path.read, permitted_classes: [Time, Date, Symbol], aliases: true) || {}
        data = data["rails_agents_database"] if data.is_a?(Hash) && data.key?("rails_agents_database")
        data.is_a?(Hash) ? data : nil
      rescue Psych::Exception
        nil
      end

      def attached_by_default?(root = nil)
        data = load(root)
        return true if data.nil? # optimistic default until install discovery runs

        data["default_attach"] != false && (
          data["active_record"] == true ||
            data["mongoid"] == true ||
            Array(data["adapters"]).any? ||
            Array(data["engines"]).any?
        )
      end

      def sql_capable?(root = nil)
        data = load(root)
        return defined?(ActiveRecord::Base) if data.nil?

        data["active_record"] == true || Array(data["engines"]).include?("active_record")
      end

      def mongoid_capable?(root = nil)
        data = load(root)
        return defined?(Mongoid) if data.nil?

        data["mongoid"] == true || Array(data["engines"]).include?("mongoid")
      end

      def primary_adapter(root = nil)
        data = load(root)
        Array(data && data["adapters"]).first || live_primary_adapter
      end

      # Static + live discovery. Safe to call from generators and runtime.
      def discover(root: nil, live: true)
        root = Pathname.new(root || default_root)
        config_files = %w[config/database.yml config/mongoid.yml]
          .select { |rel| root.join(rel).exist? }

        adapters = adapters_from_database_yml(root.join("config/database.yml"))
        has_database_yml = root.join("config/database.yml").exist?
        has_mongoid_yml = root.join("config/mongoid.yml").exist?
        mongoid = has_mongoid_yml || (live && defined?(Mongoid))
        active_record = has_database_yml || (live && defined?(ActiveRecord::Base))

        tables = []
        collections = []
        if live
          tables = live_tables if defined?(ActiveRecord::Base)
          collections = live_collections if defined?(Mongoid)
          adapters = [live_primary_adapter].compact if adapters.empty? && defined?(ActiveRecord::Base)
        end

        Result.new(
          active_record: !!active_record,
          mongoid: !!mongoid,
          adapters: adapters.uniq,
          config_files: config_files,
          tables: tables,
          collections: collections,
          default_attach: !!(active_record || mongoid)
        )
      end

      def discover!(root: nil, live: true)
        result = discover(root: root, live: live)
        write!(result, root: root)
        result
      end

      def write!(result, root: nil)
        path = config_path(root)
        FileUtils.mkdir_p(path.dirname)
        payload = {
          "version" => 1,
          "discovered_at" => Time.now.utc.iso8601,
          "default_attach" => result.default_attach,
          "active_record" => result.active_record,
          "mongoid" => result.mongoid,
          "engines" => [
            (result.active_record ? "active_record" : nil),
            (result.mongoid ? "mongoid" : nil)
          ].compact,
          "adapters" => result.adapters,
          "config_files" => result.config_files,
          "table_count" => result.tables.size,
          "collection_count" => result.collections.size,
          "tables_sample" => result.tables.first(40),
          "collections_sample" => result.collections.first(40)
        }
        path.write(YAML.dump(payload))
        path
      end

      def default_root
        defined?(Rails) && Rails.respond_to?(:root) && Rails.root ? Rails.root : Pathname.pwd
      end

      def adapters_from_database_yml(path)
        return [] unless path.file?

        raw = YAML.safe_load(
          ERB.new(path.read).result,
          permitted_classes: [Symbol],
          aliases: true
        ) || {}
        env = defined?(Rails) ? Rails.env.to_s : (ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development")
        entry = raw[env] || raw["development"] || raw.values.find { |v| v.is_a?(Hash) }
        return [] unless entry.is_a?(Hash)

        # Multi-db: primary / animals / etc.
        if entry.values.any? { |v| v.is_a?(Hash) && (v["adapter"] || v[:adapter]) }
          entry.filter_map do |_name, cfg|
            next unless cfg.is_a?(Hash)

            normalize_adapter(cfg["adapter"] || cfg[:adapter])
          end
        else
          [normalize_adapter(entry["adapter"] || entry[:adapter])].compact
        end
      rescue StandardError
        []
      end

      def normalize_adapter(adapter)
        value = adapter.to_s.downcase
        return nil if value.empty?
        return "postgresql" if value.match?(/postgres|postgis|cockroach/)
        return "mysql" if value.match?(/mysql|trilogy|maria/)
        return "sqlite" if value.include?("sqlite")
        return "sqlserver" if value.include?("sqlserver")
        return "oracle" if value.include?("oracle")

        value
      end

      def live_primary_adapter
        return nil unless defined?(ActiveRecord::Base)

        cfg = ActiveRecord::Base.connection_db_config
        normalize_adapter(cfg.adapter)
      rescue StandardError
        nil
      end

      def live_tables
        ActiveRecord::Base.connection.tables
          .reject { |t| t.start_with?("ar_", "solid_", "schema_migrations", "ar_internal_metadata") }
          .sort
      rescue StandardError
        []
      end

      def live_collections
        return [] unless defined?(Mongoid) && Mongoid.respond_to?(:default_client)

        Mongoid.default_client.database.collection_names
          .reject { |name| name.start_with?("system.") }
          .sort
      rescue StandardError
        []
      end
    end
  end
end
