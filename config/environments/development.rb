Sufia::Engine.configure do
  config.contact_email = 'archivesphere-support@dlt.psu.edu'
  config.from_email = "ArchiveSphere Form <archivesphere-support@dlt.psu.edu>"
  config.logout_url = 'https://webaccess.psu.edu/cgi-bin/logout?http://localhost/'
  config.login_url = 'https://webaccess.psu.edu?cosign-localhost&https://localhost/'
end

Archivesphere::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Expands the lines which load the assets
  config.assets.debug = true

  config.eager_load = false
end
