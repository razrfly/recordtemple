module ApplicationHelper
  include Pagy::Frontend

  # Generate URL for Active Storage variants
  # Uses Rails proxy mode - CDN (CloudFlare) caches the proxied response
  # This is the Rails-recommended approach for CDN integration
  def cdn_image_url(variant)
    rails_representation_url(variant)
  end

  # Generate URL for original blobs (unprocessed attachments)
  def cdn_blob_url(blob)
    rails_blob_url(blob)
  end

  # Convert country name/code to flag emoji
  # Uses regional indicator symbols (🇺🇸 = U+1F1FA U+1F1F8)
  COUNTRY_CODES = {
    "US" => "US", "USA" => "US", "United States" => "US", "U.S." => "US",
    "UK" => "GB", "United Kingdom" => "GB", "England" => "GB", "Great Britain" => "GB",
    "Germany" => "DE", "West Germany" => "DE", "East Germany" => "DE",
    "France" => "FR",
    "Japan" => "JP",
    "Canada" => "CA",
    "Australia" => "AU",
    "Italy" => "IT",
    "Spain" => "ES",
    "Netherlands" => "NL", "Holland" => "NL",
    "Brazil" => "BR",
    "Mexico" => "MX",
    "Sweden" => "SE",
    "Belgium" => "BE",
    "Switzerland" => "CH",
    "Austria" => "AT",
    "Argentina" => "AR",
    "Ireland" => "IE",
    "New Zealand" => "NZ",
    "Portugal" => "PT",
    "Norway" => "NO",
    "Denmark" => "DK",
    "Finland" => "FI",
    "Greece" => "GR",
    "Poland" => "PL",
    "Russia" => "RU", "USSR" => "RU",
    "South Korea" => "KR", "Korea" => "KR",
    "China" => "CN",
    "India" => "IN",
    "South Africa" => "ZA"
  }.freeze

  def country_flag_emoji(country)
    return "🌍" if country.blank?

    # Try to find the country code
    code = COUNTRY_CODES[country] || country.upcase[0, 2]

    # Convert 2-letter code to regional indicator symbols
    # A = U+1F1E6, B = U+1F1E7, etc.
    if code.length == 2 && code.match?(/^[A-Z]{2}$/)
      code.chars.map { |c| (0x1F1E6 + c.ord - 65).chr(Encoding::UTF_8) }.join
    else
      "🌍"
    end
  end
end
