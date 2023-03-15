Sentry.init do |config|
  config.dsn = 'https://d379ce887ae5465e9beb5fd631e8165f@o4504100383293440.ingest.sentry.io/4504842315956224'
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]

  # Set traces_sample_rate to 1.0 to capture 100%
  # of transactions for performance monitoring.
  # We recommend adjusting this value in production.
  config.traces_sample_rate = 1.0
  # or
  config.traces_sampler = lambda do |context|
    true
  end
end