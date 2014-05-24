require File.expand_path('../boot', __FILE__)

require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "sprockets/railtie"

Bundler.require(:default, Rails.env)

class Application < Rails::Application
  def self.error_routes
    @error_routes ||= ActionDispatch::Routing::RouteSet.new
  end
  token_file = Rails.root.join("tmp/token.txt")
  token_file.open("w") do |io|
    io.puts SecureRandom.hex(30)
  end unless token_file.exist?
  config.secret_key_base = token_file.read
  config.filter_parameters += [:password]
  config.session_store :cookie_store, key: '_session'
  config.autoload_paths += ["#{config.root}/lib/"]
  config.exceptions_app = self.error_routes
  config.generators do |g|
    g.helper false
    g.stylesheets false
    g.javascripts false
  end
end

ActiveSupport.on_load(:action_controller) do
  wrap_parameters format: [:json] if respond_to?(:wrap_parameters)
end

Slim::Engine.set_default_options sort_attrs: false, format: :html5
