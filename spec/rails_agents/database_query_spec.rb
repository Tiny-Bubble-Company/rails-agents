# frozen_string_literal: true

require "spec_helper"
require "rails_agents/database_query"

RSpec.describe RailsAgents::DatabaseQuery do
  describe ".apply_row_limit" do
    it "appends LIMIT for postgres/mysql/sqlite" do
      expect(described_class.apply_row_limit("SELECT 1", "postgresql")).to eq("SELECT 1 LIMIT 50")
      expect(described_class.apply_row_limit("SELECT 1", "mysql")).to eq("SELECT 1 LIMIT 50")
      expect(described_class.apply_row_limit("SELECT 1", "sqlite")).to eq("SELECT 1 LIMIT 50")
    end

    it "leaves existing LIMIT alone" do
      expect(described_class.apply_row_limit("SELECT 1 LIMIT 10", "postgresql")).to eq("SELECT 1 LIMIT 10")
    end

    it "uses TOP wrapper for sqlserver" do
      sql = described_class.apply_row_limit("SELECT id FROM users", "sqlserver")
      expect(sql).to include("TOP 50")
    end

    it "uses ROWNUM for oracle" do
      sql = described_class.apply_row_limit("SELECT id FROM users", "oracle")
      expect(sql).to include("ROWNUM <= 50")
    end
  end
end
