require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

class Application < Rails::Application
  
  config.autoload_paths += ["#{config.root}/lib/"]
  config.exceptions_app = lambda do |env|
    env["PATH_INFO"] = "/errors#{env["PATH_INFO"]}"
    self.routes.call(env)
  end
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.raise_delivery_errors = true
  config.filter_parameters += [:password]
  config.secret_key_base = ENV['SECRET_KEY_BASE']
  config.session_store :cookie_store, key: '_session'
  
  config.generators do |g|
    g.helper false
    g.stylesheets false
    g.javascripts false
  end

  unless Rails.env.development?
    config.middleware.use ExceptionNotification::Rack, email: {
      email_prefix: ENV["EXCEPTION_PREFIX"],
      sender_address: ENV["EXCEPTION_SENDER"],
      exception_recipients: ENV["EXCEPTION_RECIPIENTS"]
    }
  end
  
end

Slim::Engine.set_default_options sort_attrs: false, format: :html5

Rails.application.routes.default_url_options[:host] = ENV['DEFAULT_URL_HOST']
