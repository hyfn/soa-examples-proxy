require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)


class Authorization
  BRAND_IDS = 1.upto(100000)

  def initialize(app)
    @app = app
  end

  def call(env)
    # middleware stuff
    # binding.pry
    # env['HTTP_ACL'] = {
    #   :foo => "Bar"
    # }.to_json

    env['HTTP_ACL'] = {
      brand_id: BRAND_IDS
    }.to_json


    @app.call(env)
  end
end

class ThisProxy < Rack::Proxy
  def initialize(app, options = {})
    @app = app
    super(options)
  end
end

module Proxy
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    config.middleware.use(Authorization)
    config.middleware.use(ThisProxy, backend: "http://localhost:3006")

    # binding.pry

  end
end
