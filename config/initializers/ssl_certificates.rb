# Fix SSL certificate verification issues in development
# The AWS SDK has trouble with Homebrew OpenSSL's certificate chain
if Rails.env.development?
  require "aws-sdk-s3"
  Aws.config.update(
    ssl_ca_bundle: "/etc/ssl/cert.pem"
  )
end
