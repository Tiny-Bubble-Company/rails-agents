# frozen_string_literal: true

module RailsAgents
  # Compatibility helpers so the engine can run on Rails 6.1+ (and 7/8).
  # Rails 3–5 are not supported: they cannot run on Ruby 3.2+, which this gem requires.
  module Compat
    module_function

    def rails_major
      ::Rails::VERSION::MAJOR
    rescue StandardError
      0
    end

    def rails_minor
      ::Rails::VERSION::MINOR
    rescue StandardError
      0
    end

    def at_least?(major, minor = 0)
      rails_major > major || (rails_major == major && rails_minor >= minor)
    end

    def zeitwerk?
      defined?(::Rails) &&
        ::Rails.respond_to?(:autoloaders) &&
        ::Rails.autoloaders.respond_to?(:main) &&
        ::Rails.autoloaders.main
    end

    def application_name
      return "App" unless defined?(::Rails)

      klass = ::Rails.application.class
      if klass.respond_to?(:module_parent_name)
        klass.module_parent_name
      elsif klass.respond_to?(:parent_name)
        klass.parent_name
      else
        klass.name.to_s.split("::").first
      end
    rescue StandardError
      "App"
    end

    # Rails 7+ open-redirect protection requires allow_other_host: true.
    def redirect_options
      at_least?(7, 0) ? { allow_other_host: true } : {}
    end

    def skip_csrf!(controller_class)
      if controller_class.respond_to?(:skip_forgery_protection)
        controller_class.skip_forgery_protection
      elsif controller_class.respond_to?(:skip_before_action)
        controller_class.skip_before_action :verify_authenticity_token, raise: false
      end
    end
  end
end
