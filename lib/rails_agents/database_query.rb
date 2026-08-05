# frozen_string_literal: true

module RailsAgents
  # Read-only database query helpers for Tool Bridge.
  # Supports ActiveRecord SQL dialects and Mongoid collection finds.
  module DatabaseQuery
    module_function

    FORBIDDEN_SQL = /\b(INSERT|UPDATE|DELETE|DROP|ALTER|TRUNCATE|CREATE|GRANT|REVOKE|COPY|EXECUTE|CALL|MERGE|REPLACE)\b/i

    def sql_query(sql, adapter: nil)
      raise ArgumentError, "ActiveRecord is not available" unless defined?(ActiveRecord::Base)

      text = sql.to_s.strip
      raise ArgumentError, "sql is required" if text.empty?

      normalized = text.sub(/;\s*\z/, "")
      unless normalized.match?(/\A\s*(WITH|SELECT)\b/im)
        raise ArgumentError, "Only read-only SELECT/WITH queries are allowed"
      end
      raise ArgumentError, "Write or DDL statements are not allowed" if normalized.match?(FORBIDDEN_SQL)

      limited = apply_row_limit(normalized, adapter || DatabaseDiscovery.primary_adapter)
      rows = ActiveRecord::Base.connection.exec_query(limited).to_a
      {
        ok: true,
        engine: "active_record",
        adapter: adapter || DatabaseDiscovery.primary_adapter,
        row_count: rows.length,
        rows: rows.first(50)
      }
    end

    def mongo_query(collection:, filter: nil, limit: 50, projection: nil)
      raise ArgumentError, "Mongoid is not available" unless defined?(Mongoid) && Mongoid.respond_to?(:default_client)

      name = collection.to_s.strip
      raise ArgumentError, "collection is required" if name.empty?
      raise ArgumentError, "Invalid collection name" unless name.match?(/\A[A-Za-z0-9_.-]+\z/)

      lim = [[limit.to_i, 1].max, 50].min
      criteria = filter.is_a?(Hash) ? filter : {}
      coll = Mongoid.default_client[name]
      cursor = coll.find(criteria)
      cursor = cursor.sort(projection) if projection.is_a?(Hash) && !projection.empty?
      docs = cursor.limit(lim).to_a.map { |doc| stringify_bson(doc) }
      {
        ok: true,
        engine: "mongoid",
        collection: name,
        row_count: docs.length,
        rows: docs
      }
    end

    def apply_row_limit(sql, adapter)
      return sql if sql.match?(/\bLIMIT\b/i) || sql.match?(/\bFETCH\s+FIRST\b/i) || sql.match?(/\bTOP\s+\d+/i)

      case adapter.to_s
      when "sqlserver"
        # Best-effort: wrap as subquery when TOP absent
        "SELECT TOP 50 * FROM (#{sql}) AS rails_agents_q"
      when "oracle"
        "SELECT * FROM (#{sql}) rails_agents_q WHERE ROWNUM <= 50"
      else
        # postgresql, mysql, sqlite, trilogy, etc.
        "#{sql} LIMIT 50"
      end
    end

    def stringify_bson(value)
      case value
      when Hash
        value.transform_keys(&:to_s).transform_values { |v| stringify_bson(v) }
      when Array
        value.map { |v| stringify_bson(v) }
      else
        if defined?(BSON::ObjectId) && value.is_a?(BSON::ObjectId)
          value.to_s
        else
          value
        end
      end
    rescue StandardError
      value.inspect
    end
  end
end
