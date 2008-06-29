# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# RailsDB configuration
require File.join(File.dirname(__FILE__), 'railsdb_config')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  # config.action_controller.session = {
  #   :session_key => '_railsdb_session',
  #   :secret      => '3e1169688926f48ca8731b64a1c3c2126a53404c1527cd97b7db1e87998f4f619b48461c9536a068ac218e6bdb8c551edccbd1c46f82db0b8d7a3f8cced8549c'
  # }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

#
# TODO: Trademark this?  Nah..
#
SITE_TITLE = 'RailsDB'

#
# How many rows per page
#
PER_PAGE = 20

#
# How many links to show on each side of current page
#
LINK_SPAN = 4

#
# Fixes for irregular pluralizations
#
Inflector.inflections.irregular 'database', 'databases'

#
# Dynamic table names can't override core Ruby/Rails classes
#
ALT_TABLE_NAMES = { 'proc'      => 'proc_renamed',      # mysql
                    'time_zone' => 'time_zone_renamed'  # mysql
                    }

#
# Potential attributes of a field
#
FIELD_ATTRIBUTES = %w( name type null limit default scale precision )

#
# Table types, taken from:
# http://api.rubyonrails.com/classes/ActiveRecord/ConnectionAdapters/TableDefinition.html#M001222
#
def get_field_types( driver )
  field_types = %w( string text integer float decimal timestamp time date binary boolean primary_key )
  %w( datetime ).each { |f| field_types << f } unless driver == 'postgresql'
  field_types.sort
end

#
# Only include options that are actually present
#
def mangle_column_options( params, index )
  opts = {}
  opts[:null]       = true if params[:fields][index][:null] == '1'
  opts[:default]    = params[:fields][index][:default]        unless params[:fields][index][:default].empty?
  opts[:limit]      = params[:fields][index][:limit].to_i     unless params[:fields][index][:limit].empty?
  opts[:scale]      = params[:fields][index][:scale].to_i     unless params[:fields][index][:scale].empty?
  opts[:precision]  = params[:fields][index][:precision].to_i unless params[:fields][index][:precision].empty?
  opts
end
