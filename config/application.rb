require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
Dotenv::Railtie.load if defined?(Dotenv::Railtie)

module ShiftScheduling
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
    config.i18n.default_locale = :ja 
    config.active_record.default_timezone = :local
    config.time_zone = 'Asia/Tokyo'   
    
    config.generators do |g|
      config.generators.test_framework = :rspec
      config.generators.system_tests   = false
      config.generators.stylesheets    = false
      config.generators.javascripts    = false
      config.generators.helper         = false
    end
  end
end
