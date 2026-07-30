# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# Until open-wire is on RubyGems, source from the sibling Open-Wire repo
# (Hetzner: /opt/meerkat-apps/open-wire/ruby).
open_wire_path = ENV.fetch("OPEN_WIRE_GEM_PATH") do
  File.expand_path("../open-wire/ruby", __dir__)
end
gem "open-wire", path: open_wire_path

gem "rake", "~> 13.0"
gem "rspec", "~> 3.13"
gem "webmock", "~> 3.23"
