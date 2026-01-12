# frozen_string_literal: true

# Service for finding or fetching DiscogsRelease records.
# Caches Discogs API responses in the local database.
#
# Usage:
#   service = DiscogsReleaseService.new
#   release = service.find_or_fetch(2750183)  # by Discogs ID
#   release = service.find_or_fetch_from_search_result(result_hash)
#
class DiscogsReleaseService
  def initialize(api_client: nil)
    @api = api_client || DiscogsApiClient.new
  end

  # Find existing DiscogsRelease or fetch from API and create
  # Handles race condition when concurrent calls create the same release
  def find_or_fetch(discogs_id)
    DiscogsRelease.find_by(discogs_id: discogs_id) || fetch_and_create(discogs_id)
  rescue ActiveRecord::RecordNotUnique
    # Another process created it first - find and return it
    DiscogsRelease.find_by!(discogs_id: discogs_id)
  end

  # Create DiscogsRelease from a search result (partial data)
  # Will fetch full release details if needed for complete data
  # Handles race condition when concurrent calls create the same release
  def find_or_fetch_from_search_result(result, fetch_full: false)
    discogs_id = result["id"]
    existing = DiscogsRelease.find_by(discogs_id: discogs_id)
    return existing if existing

    if fetch_full
      fetch_and_create(discogs_id)
    else
      create_from_search_result(result)
    end
  rescue ActiveRecord::RecordNotUnique
    # Another process created it first - find and return it
    DiscogsRelease.find_by!(discogs_id: discogs_id)
  end

  # Refresh an existing DiscogsRelease with latest API data
  def refresh!(discogs_release)
    response = @api.get_release(discogs_release.discogs_id)
    update_from_api_response(discogs_release, response)
    discogs_release
  end

  private

  def fetch_and_create(discogs_id)
    response = @api.get_release(discogs_id)
    create_from_api_response(response)
  rescue DiscogsApiClient::NotFoundError
    Rails.logger.warn("Discogs release #{discogs_id} not found")
    nil
  end

  def create_from_api_response(response)
    DiscogsRelease.create!(
      discogs_id: response["id"],
      master_id: response["master_id"],
      title: response["title"],
      year: response["year"],
      country: response["country"],
      catno: extract_catno(response),
      artists: response["artists"] || [],
      labels: response["labels"] || [],
      formats: response["formats"] || [],
      tracklist: response["tracklist"] || [],
      genres: response["genres"] || [],
      styles: response["styles"] || [],
      images: response["images"] || [],
      community_have: response.dig("community", "have"),
      community_want: response.dig("community", "want"),
      lowest_price: response["lowest_price"],
      raw_response: response,
      fetched_at: Time.current
    )
  end

  def create_from_search_result(result)
    # Search results have less data than full release
    DiscogsRelease.create!(
      discogs_id: result["id"],
      master_id: result["master_id"],
      title: result["title"],
      year: result["year"]&.to_i,
      country: result["country"],
      catno: result["catno"],
      artists: extract_artists_from_search(result),
      labels: extract_labels_from_search(result),
      formats: extract_formats_from_search(result),
      tracklist: [],
      genres: result["genre"] || [],
      styles: result["style"] || [],
      images: extract_images_from_search(result),
      community_have: result.dig("community", "have"),
      community_want: result.dig("community", "want"),
      raw_response: result,
      fetched_at: Time.current
    )
  end

  def update_from_api_response(discogs_release, response)
    discogs_release.update!(
      master_id: response["master_id"],
      title: response["title"],
      year: response["year"],
      country: response["country"],
      catno: extract_catno(response),
      artists: response["artists"] || [],
      labels: response["labels"] || [],
      formats: response["formats"] || [],
      tracklist: response["tracklist"] || [],
      genres: response["genres"] || [],
      styles: response["styles"] || [],
      images: response["images"] || [],
      community_have: response.dig("community", "have"),
      community_want: response.dig("community", "want"),
      lowest_price: response["lowest_price"],
      raw_response: response,
      fetched_at: Time.current
    )
  end

  def extract_catno(response)
    response.dig("labels", 0, "catno") || response["catno"]
  end

  def extract_artists_from_search(result)
    # Search results have artists as string in title "Artist - Title"
    # or in the "title" field
    if result["title"]&.include?(" - ")
      artist_name = result["title"].split(" - ").first
      [{ "name" => artist_name }]
    else
      []
    end
  end

  def extract_labels_from_search(result)
    # Search results have label as array of strings
    labels = result["label"] || []
    catno = result["catno"]
    labels.map { |name| { "name" => name, "catno" => catno } }
  end

  def extract_formats_from_search(result)
    # Search results have format as array of strings
    formats = result["format"] || []
    [{ "name" => formats.first, "descriptions" => formats.drop(1) }]
  end

  def extract_images_from_search(result)
    images = []
    images << { "type" => "primary", "uri" => result["cover_image"] } if result["cover_image"].present?
    images << { "type" => "thumb", "uri" => result["thumb"] } if result["thumb"].present?
    images
  end
end
