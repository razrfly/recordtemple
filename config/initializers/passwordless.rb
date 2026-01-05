# Passwordless v1.x configuration
Passwordless.configure do |config|
  config.default_from_address = "no-reply@recordtemple.com"
  config.parent_mailer = "ActionMailer::Base"
  config.restrict_token_reuse = false

  # Session expiry (how long until a passwordless session expires)
  config.expires_at = lambda { 1.year.from_now }

  # Token expiry (how long until a magic link expires)
  config.timeout_at = lambda { 1.hour.from_now }

  # Redirect back to previous page after sign in
  config.redirect_back_after_sign_in = true

  # Default redirection paths
  config.success_redirect_path = "/"
  config.failure_redirect_path = "/"
  config.sign_out_redirect_path = "/"
end
