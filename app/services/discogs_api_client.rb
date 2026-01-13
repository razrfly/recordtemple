# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

# Low-level client for Discogs API with rate limiting and error handling.
#
# Usage:
#   client = DiscogsApiClient.new
#   client.search(artist: "AC/DC", year: 1976)
#   client.get_release(2750183)
#
# Rate limiting:
#   - Discogs allows 60 requests/minute for authenticated requests
#   - This client enforces 1 request/second to stay safely under limits
#   - Respects X-Discogs-Ratelimit-Remaining header
#
class DiscogsApiClient
  class Error < StandardError; end
  class RateLimitError < Error; end
  class NotFoundError < Error; end
  class AuthenticationError < Error; end

  BASE_URL = "https://api.discogs.com"
  USER_AGENT = "RecordTemple/1.0 +https://recordtemple.com"
  MIN_REQUEST_INTERVAL = 1.0 # seconds between requests

  def initialize(token: nil)
    @token = token || ENV["DISCOGS_API_TOKEN"] || Rails.application.credentials.dig(:discogs, :api_token)
    raise AuthenticationError, "Discogs API token not configured. Set DISCOGS_API_TOKEN env var or add to credentials." if @token.blank?
    @last_request_at = nil
    @rate_limit_remaining = 60
  end

  # Search for releases matching criteria
  # Returns hash with :pagination and :results keys
  def search(artist: nil, label: nil, year: nil, catno: nil, barcode: nil, per_page: 10, page: 1)
    params = { per_page: per_page, page: page, type: "release" }
    params[:artist] = artist if artist.present?
    params[:label] = label if label.present?
    params[:year] = year if year.present?
    params[:catno] = catno if catno.present?
    params[:barcode] = barcode if barcode.present?

    get("/database/search", params)
  end

  # Get full release details by Discogs release ID
  def get_release(release_id)
    get("/releases/#{release_id}")
  end

  # Get master release (canonical version across pressings)
  def get_master(master_id)
    get("/masters/#{master_id}")
  end

  # Check current rate limit status
  def rate_limit_remaining
    @rate_limit_remaining
  end

  private

  def get(path, params = {})
    enforce_rate_limit!

    uri = URI("#{BASE_URL}#{path}")
    uri.query = URI.encode_www_form(params) if params.any?

    request = Net::HTTP::Get.new(uri)
    request["Authorization"] = "Discogs token=#{@token}"
    request["User-Agent"] = USER_AGENT
    request["Accept"] = "application/vnd.discogs.v2.discogs+json"

    response = execute_request(uri, request)
    handle_response(response)
  end

  def execute_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.open_timeout = 10
    http.read_timeout = 30

    # Configure SSL to handle certificate verification robustly
    # Some systems have issues with CRL (Certificate Revocation List) checking
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    cert_store = OpenSSL::X509::Store.new
    cert_store.set_default_paths
    # Don't set CRL flags - this avoids "unable to get certificate CRL" errors
    http.cert_store = cert_store

    @last_request_at = Time.current
    http.request(request)
  rescue Net::OpenTimeout, Net::ReadTimeout => e
    raise Error, "Request timeout: #{e.message}"
  rescue OpenSSL::SSL::SSLError => e
    raise Error, "SSL error: #{e.message}"
  end

  def handle_response(response)
    update_rate_limit(response)

    case response.code.to_i
    when 200
      begin
        JSON.parse(response.body)
      rescue JSON::ParserError => e
        raise Error, "Invalid JSON response: #{e.message}"
      end
    when 401
      raise AuthenticationError, "Invalid Discogs token"
    when 404
      raise NotFoundError, "Resource not found"
    when 429
      retry_after = response["Retry-After"]&.to_i || 60
      raise RateLimitError, "Rate limited. Retry after #{retry_after} seconds"
    else
      raise Error, "API error #{response.code}: #{response.body}"
    end
  end

  def update_rate_limit(response)
    remaining = response["X-Discogs-Ratelimit-Remaining"]
    @rate_limit_remaining = remaining.to_i if remaining.present?
  end

  def enforce_rate_limit!
    return unless @last_request_at

    elapsed = Time.current - @last_request_at
    if elapsed < MIN_REQUEST_INTERVAL
      sleep_time = MIN_REQUEST_INTERVAL - elapsed
      sleep(sleep_time)
    end

    # Extra caution if we're running low on rate limit
    if @rate_limit_remaining < 10
      Rails.logger.warn("Discogs rate limit low: #{@rate_limit_remaining} remaining")
      sleep(2.0)
    end
  end
end
