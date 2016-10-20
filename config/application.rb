require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_model/railtie"
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"
require 'csv'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Budget
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'Kyiv'

    config.i18n.enforce_available_locales = false
    # Require available locales for app
    # to check locale params before load app
    # if need - add locale from lib I18n in format: ':locale_name'
    config.i18n.available_locales = [:en, :uk]
    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :uk

    # Use this setup block to configure all options available in AddThis
    # homepage, sidebar, left
    # horizontal, sharing
    # Karelin sharing link
    config.addthis_url = "//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-579f198770513078"
    # Dev sharing link
    # config.addthis_url = "//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-57f7636836f4b813"

    # Cross-origin resource sharing (CORS)
    config.middleware.insert_before 0, "Rack::Cors" do
      allow do
        origins '*'
        resource '*', :headers => :any, :methods => [:get, :post, :options]
      end
    end

    config.autoload_paths += %W(#{config.root}/lib)
    config.autoload_paths += %W(#{config.root}/presenters)
    config.watchable_dirs['lib'] = [:rb]
  end
end
