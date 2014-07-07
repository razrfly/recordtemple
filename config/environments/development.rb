Recordapp::Application.configure do
  # Settings specified here will take precedence over those in config/environment.rb

  # In the development environment your application's code is reloaded on
  # every request.  This slows down response time but is perfect for development
  # since you don't have to restart the webserver when you make code changes.
  config.cache_classes = false

  config.eager_load = false

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false
  
  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'recordtemple.dev' }
  
  config.action_mailer.smtp_settings = {
    :address        => 'localhost',
    :port           => 1025,
    :domain => "www.recordtemple.com"
  }

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin
  
  ENV['PANDASTREAM_URL'] = 'http://a6b1c888-0ec5-11e0-a310-12313b01e082:VYkZil+4ln2nTEPe13dv8brGN1UeqE64lhKEZSv3@api.pandastream.com:80/82e61aeb35b1db340243c40dab8ab998'
  
  #require 'hirb'
  #Hirb::View.enable
  
end

