# frozen_string_literal: true

source "https://rubygems.org"

gemspec

# open-wire comes from RubyGems via the gemspec (`~> 0.1`).
# Override locally with: OPEN_WIRE_GEM_PATH=/path/to/open-wire/ruby bundle install
if (path = ENV["OPEN_WIRE_GEM_PATH"]) && !path.empty? && File.directory?(path)
  gem "open-wire", path: path
end

gem "rake", "~> 13.0"
gem "rspec", "~> 3.13"
gem "webmock", "~> 3.23"
