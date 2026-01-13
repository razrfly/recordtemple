# frozen_string_literal: true

# Service for matching RecordTemple records to Discogs releases.
# Uses weighted confidence scoring based on artist, title, label, year, format, and price.
#
# Usage:
#   service = DiscogsMatchingService.new(record)
#   candidates = service.find_candidates     # Returns scored candidates
#   release = service.match!                 # Auto-matches if confidence high enough
#   service.link!(discogs_release, confidence: 95, method: :manual)  # Manual link
#
# Confidence Scoring:
#   - Artist similarity: 25%
#   - Title similarity: 20% (extracts from prices.detail)
#   - Label similarity: 20%
#   - Year match: 15%
#   - Format compatibility: 10%
#   - Price sanity: 10%
#
class DiscogsMatchingService
  WEIGHTS = {
    artist: 0.25,
    title: 0.20,
    label: 0.20,
    year: 0.15,
    format: 0.10,
    price: 0.10
  }.freeze

  THRESHOLDS = {
    auto_high: 85,    # Auto-link with high confidence
    auto_low: 60,     # Auto-link with lower confidence (lowered from 70 based on Phase 1C research)
    minimum: 50       # Below this, don't create a match
  }.freeze

  # Format mapping from RecordTemple to Discogs
  FORMAT_MAPPING = {
    "Singles: 7-inch" => ["7\"", "Single"],
    "Singles: 12-inch" => ["12\"", "Single"],
    "Singles: 10/12-inch" => ["Single"],  # Added: Phase 1D - 135 records
    "LPs: 10/12-inch" => ["12\"", "LP", "Album"],
    "EPs: 7-inch" => ["7\"", "EP"],
    "EPs: 7-inch 45 rpm" => ["7\"", "EP"],  # Added: Phase 1D - 7 records
    "EPs: 10-inch" => ["10\"", "EP"],
    "EPs: 12-inch" => ["12\"", "EP"],
    "Picture Sleeves" => ["7\"", "Single"],
    "Picture Disc Singles" => ["7\"", "Single", "Picture Disc"],  # Added: Phase 1D - 15 records
    "Promotional Singles" => ["7\"", "Single"],  # Added: Phase 1D - 1,113 records
    "Promotional 12-inch Singles" => ["12\"", "Single"],  # Added: Phase 1D - 3 records
    "Gold Standard Singles with '447' prefix" => ["7\"", "Single"],  # Added: Phase 1D - 44 records
    "Gold Standard Picture Sleeves" => ["7\"", "Single"],  # Added: Phase 1D - 5 records
    "Singles: 78 rpm" => ["10\"", "78 RPM"],
    "Albums: 78 rpm" => ["10\"", "78 RPM", "Album"]
  }.freeze

  def initialize(record, api_client: nil)
    @record = record
    @api = api_client || DiscogsApiClient.new
    @release_service = DiscogsReleaseService.new(api_client: @api)
  end

  # Find and score candidate matches from Discogs
  # Returns array of { candidate:, score:, factors:, discogs_release: }
  def find_candidates(limit: 5)
    search_results = search_discogs
    return [] if search_results.empty?

    search_results
      .first(limit * 2)  # Get extra to filter
      .map { |result| score_candidate(result) }
      .select { |scored| scored[:score] >= THRESHOLDS[:minimum] }
      .sort_by { |scored| -scored[:score] }
      .first(limit)
  end

  # Auto-match record to best candidate if confidence is high enough
  # Returns the DiscogsRelease if matched, nil otherwise
  # Can optionally pass pre-fetched candidates to avoid redundant API calls
  def match!(candidates: nil)
    # Skip if record already has a manual match
    if @record.discogs_release_id.present? && @record.discogs_match_method == "manual"
      return nil
    end

    candidates ||= find_candidates(limit: 3)
    return nil if candidates.empty?

    best = candidates.first
    return nil if best[:score] < THRESHOLDS[:auto_low]

    # Get or create the DiscogsRelease
    discogs_release = @release_service.find_or_fetch_from_search_result(
      best[:candidate],
      fetch_full: best[:score] >= THRESHOLDS[:auto_high]
    )
    return nil unless discogs_release

    method = best[:score] >= THRESHOLDS[:auto_high] ? "auto_high" : "auto_low"
    link!(discogs_release, confidence: best[:score], method: method)

    discogs_release
  end

  # Manually link a record to a DiscogsRelease
  def link!(discogs_release, confidence:, method: "manual")
    @record.update!(
      discogs_release: discogs_release,
      discogs_confidence: confidence,
      discogs_match_method: method,
      discogs_matched_at: Time.current
    )
  end

  # Unlink a record from its DiscogsRelease
  def unlink!
    @record.update!(
      discogs_release: nil,
      discogs_confidence: nil,
      discogs_match_method: nil,
      discogs_matched_at: nil
    )
  end

  private

  def search_discogs
    artist = @record.artist&.name || @record.cached_artist
    label = @record.label&.name || @record.cached_label
    # Use positive? to avoid passing year=0 to API (0.present? is true in Ruby)
    year = @record.yearbegin.to_i.positive? ? @record.yearbegin : nil

    return [] if artist.blank?

    # Try most specific search first
    results = @api.search(artist: artist, label: label, year: year, per_page: 10)
    return results["results"] if results["results"].any?

    # Try without year (year might be off)
    results = @api.search(artist: artist, label: label, per_page: 10)
    return results["results"] if results["results"].any?

    # Try just artist + year
    if year
      results = @api.search(artist: artist, year: year, per_page: 10)
      return results["results"] if results["results"].any?
    end

    # Fallback to just artist
    results = @api.search(artist: artist, per_page: 10)
    results["results"] || []
  end

  def score_candidate(candidate)
    factors = {
      artist: calculate_artist_score(candidate),
      title: calculate_title_score(candidate),
      label: calculate_label_score(candidate),
      year: calculate_year_score(candidate),
      format: calculate_format_score(candidate),
      price: calculate_price_score(candidate)
    }

    total_score = factors.sum { |factor, score| score * WEIGHTS[factor] }

    {
      candidate: candidate,
      score: total_score.round(2),
      factors: factors
    }
  end

  def calculate_artist_score(candidate)
    # Use normalize_artist_name to flip "LASTNAME, First" to "First Lastname"
    record_artist = normalize_artist_name(@record.artist&.name || @record.cached_artist)
    return 0 if record_artist.blank?

    # Extract artist from candidate title (format: "Artist - Title")
    discogs_artist = extract_artist_from_title(candidate["title"])
    return 0 if discogs_artist.blank?

    similarity(record_artist, discogs_artist)
  end

  def calculate_title_score(candidate)
    # Extract title(s) from prices.detail (format: '7410 "One Night"' or '7410 "Song1"/"Song2"')
    record_titles = extract_titles_from_detail(@record.price&.detail)
    return 50 if record_titles.empty?  # Neutral if no title data

    # Extract title from Discogs candidate (format: "Artist - Title")
    discogs_title = extract_release_title_from_candidate(candidate["title"])
    return 50 if discogs_title.blank?  # Neutral if no Discogs title

    # Find best matching title (handles A-side/B-side scenarios)
    best_match = record_titles.map { |t| similarity(normalize_name(t), discogs_title) }.max
    best_match || 0
  end

  def calculate_label_score(candidate)
    record_label = normalize_name(@record.label&.name || @record.cached_label)
    return 50 if record_label.blank?  # Neutral if we don't have label data

    discogs_labels = candidate["label"] || []
    return 50 if discogs_labels.empty?

    # Find best matching label
    best_match = discogs_labels.map { |l| similarity(record_label, normalize_name(l)) }.max
    best_match || 0
  end

  def calculate_year_score(candidate)
    record_year = @record.yearbegin
    return 50 if record_year.blank? || record_year.zero?  # Neutral if no year

    discogs_year = candidate["year"]&.to_i
    return 50 if discogs_year.blank? || discogs_year.zero?

    diff = (record_year - discogs_year).abs
    case diff
    when 0 then 100
    when 1 then 80
    when 2 then 50
    else 0
    end
  end

  def calculate_format_score(candidate)
    record_format = @record.record_format&.name
    return 50 if record_format.blank?  # Neutral if no format

    discogs_formats = candidate["format"] || []
    return 50 if discogs_formats.empty?

    # Check if RecordTemple format maps to any Discogs format
    expected_terms = FORMAT_MAPPING[record_format] || []
    if expected_terms.empty?
      # Unknown format - partial match if it's vinyl
      return discogs_formats.any? { |f| f.downcase.include?("vinyl") } ? 70 : 30
    end

    # Count how many expected terms are present
    matches = expected_terms.count { |term| discogs_formats.any? { |f| f.downcase.include?(term.downcase) } }
    return 100 if matches == expected_terms.length
    return 70 if matches > 0
    30
  end

  def calculate_price_score(candidate)
    # Use price guide data if available for sanity check
    price = @record.price
    return 50 if price.nil?  # Neutral if no price guide

    price_high = price.price_high
    return 50 if price_high.nil? || price_high.zero?

    # Discogs community have/want as rough value indicator
    have = candidate.dig("community", "have") || 0
    want = candidate.dig("community", "want") || 0

    # Very common records (high have count) are usually cheaper
    # Rare records (high want/have ratio) are usually expensive
    if have > 1000 && price_high > 100
      # Common on Discogs but expensive in price guide - possible mismatch
      return 50
    elsif have < 50 && price_high < 20
      # Rare on Discogs but cheap in price guide - possible mismatch
      return 50
    end

    # Default: trust the match
    75
  end

  # Simple string similarity using trigrams
  def similarity(str1, str2)
    return 100 if str1 == str2

    trigrams1 = trigrams(str1)
    trigrams2 = trigrams(str2)

    return 0 if trigrams1.empty? || trigrams2.empty?

    intersection = (trigrams1 & trigrams2).length
    union = (trigrams1 | trigrams2).length

    ((intersection.to_f / union) * 100).round
  end

  def trigrams(str)
    return [] if str.length < 3
    (0..str.length - 3).map { |i| str[i, 3] }
  end

  def normalize_name(name)
    return "" if name.blank?
    name.to_s.downcase.gsub(/[^a-z0-9\s]/, "").gsub(/\s+/, " ").strip
  end

  # Normalize artist name, flipping "LASTNAME, First" to "First Lastname"
  # This improves trigram matching since Discogs uses "First Lastname" format
  def normalize_artist_name(name)
    return "" if name.blank?

    # Check for "LASTNAME, First" pattern (common in RecordTemple data)
    # Matches: "PRESLEY, Elvis", "McCARTNEY, Paul", "LEWIS, Jerry Lee"
    if name =~ /^([A-Z][A-Za-z']+),\s*(.+)$/
      name = "#{$2} #{$1}"  # Flip to "First Lastname"
    end

    normalize_name(name)
  end

  def extract_artist_from_title(title)
    return "" if title.blank?
    # Discogs titles are formatted as "Artist - Title"
    parts = title.split(" - ", 2)
    normalize_name(parts.first)
  end

  # Extract release title from Discogs candidate title (format: "Artist - Title")
  def extract_release_title_from_candidate(title)
    return "" if title.blank?
    parts = title.split(" - ", 2)
    return "" if parts.length < 2
    normalize_name(parts.last)
  end

  # Extract song title(s) from prices.detail
  # Formats handled:
  #   '7410 "One Night"'              -> ["One Night"]
  #   '7410 "Song1"/"Song2"'          -> ["Song1", "Song2"]
  #   '99177/99178 "Stormy"/"Let Me"' -> ["Stormy", "Let Me"]
  #   '992 Elvis, Vol. 1'             -> ["Elvis, Vol. 1"] (no quotes = use whole thing after catalog)
  def extract_titles_from_detail(detail)
    return [] if detail.blank?

    # Try to extract quoted titles first (most reliable)
    quoted_titles = detail.scan(/"([^"]+)"/).flatten
    return quoted_titles if quoted_titles.any?

    # Fallback: remove catalog number prefix and use remainder
    # Catalog numbers START with digits, optionally followed by letters/slashes
    # Pattern: digits at start, optionally with /, letters, or hyphens, then space
    remainder = detail.sub(/^\d[\d\/A-Za-z-]*\s+/, "").strip
    return [] if remainder.blank? || remainder == detail

    [remainder]
  end
end
