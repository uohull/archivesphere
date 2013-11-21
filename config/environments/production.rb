Sufia::Engine.configure do
  config.contact_email = 'archivesphere-support@dlt.psu.edu'
  config.from_email = "ArchiveSphere Form <archivesphere-support@dlt.psu.edu>"
  #if we redirect back to the site after logout it does not make much sense since a user must be logged in to access the system
  #currently just redirecting to the libraries home page.  This may need to change in the future
  config.logout_url = "https://webaccess.psu.edu/cgi-bin/logout?http://www.libraries.psu.edu"
#  config.logout_url = "https://webaccess.psu.edu/cgi-bin/logout?#{Rails.application.get_vhost_by_host[1]}"
  config.login_url = "https://webaccess.psu.edu?cosign-#{Rails.application.get_vhost_by_host[0]}&#{Rails.application.get_vhost_by_host[1]}"
end
Archivesphere::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Code is not reloaded between requests
  config.cache_classes = true

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true

  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false

  # Compress JavaScripts and CSS
  config.assets.compress = true

  # Don't fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = false

  # Generate digests for assets URLs
  config.assets.digest = true

  # Defaults to nil and saved in location specified by config.assets.prefix
  # config.assets.manifest = YOUR_PATH

  # Specifies the header that your server uses for sending files
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # See everything in the log (default is :info)
  # config.log_level = :debug

  # Prepend all log lines with the following tags
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets (application.js, application.css, and all non-JS/CSS are already added)
  # config.assets.precompile += %w( search.js )

  # Disable delivery errors, bad email addresses will be ignored
  # config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :sendmail

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found)
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners
  config.active_support.deprecation = :notify

  config.eager_load = false
  config.assets.js_compressor = :uglifier

  config.action_dispatch.x_sendfile_header = "X-Sendfile"
  config.cache_store = :mem_cache_store
  config.action_dispatch.default_headers = {
    'X-Frame-Options' => 'SAMEORIGIN',
       'X-XSS-Protection' => '1; mode=block',
       'X-Content-Type-Options' => 'nosniff'
    }

  config.force_ssl = true

end
