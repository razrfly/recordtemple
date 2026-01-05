# Enable proxy mode for Active Storage
# Files are served through the Rails app instead of redirecting to S3 signed URLs
# This allows CloudFlare (or any CDN) to cache responses at the edge
#
# Request flow: User → CloudFlare → Fly.io/Rails → S3 → cached at edge
Rails.application.config.active_storage.resolve_model_to_route = :rails_storage_proxy
