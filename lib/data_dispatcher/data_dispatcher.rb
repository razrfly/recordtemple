class DataDispatcher
  include Utils
  include Stats

  SOURCE_FILES = %w(a-d.html e-k.html l-q.html r-z.html)
  SOURCE_CONFIG = {
    'a-d.html' => {
      allowed_paragraphs: %w(p2 p3 p4),
      artist_paragraph: 'p2',
      record_format_paragraph: 'p3'
    },
    'e-k.html' => {
      allowed_paragraphs: %w(p3 p5 p6),
      artist_paragraph: 'p3',
      record_format_paragraph: 'p5'
    },
    'l-q.html' => {},
    'r-z.html' => {}
  }

  def initialize(file_name)
    @file_name = file_name
  end

  def execute!
    set_start_time
    create_file_path
    load_file
    parse_file_with_nokogiri
    fetch_allowed_paragraphs
    create_artists_namespaces

    artists.first(10).each do |artist|
      prepare_prices_data(artist).each do |data|
        prices << data
      end
    end

    fire_price_judgement!

    fire_stats!

    execute_time
  end

  private
  attr_reader :file_name, :file_path, :original_file, :parsed_file, :paragraphs,
    :artists, :prices

  def create_file_path
    @file_path = Rails.root.join('lib', 'data_dispatcher', file_name)
  end

  def load_file
    execute_message(__callee__)

    File.exist?(file_path) && @original_file = open(file_path)
    execute_time
  end

  def parse_file_with_nokogiri
    execute_message(__callee__)

    @parsed_file = Nokogiri::HTML(original_file) do |config|
      config.options |= Nokogiri::XML::ParseOptions::HUGE |
        Nokogiri::XML::ParseOptions::NOBLANKS
    end
    execute_time
  end

  def fetch_allowed_paragraphs
    execute_message(__callee__)
    allowed_paragraphs = SOURCE_CONFIG[file_name][:allowed_paragraphs]

    @paragraphs = Array(parsed_file.css('p')).keep_if do |paragraph|
      allowed_paragraphs.include? paragraph.attr('class')
    end
    execute_time
  end

  def create_artists_namespaces
    execute_message(__callee__)

    @artists = paragraphs.slice_before do |paragraph|
      paragraph.attr('class') == SOURCE_CONFIG[file_name][:artist_paragraph]
    end
    execute_time
  end

  def prices
    @@prices ||= {}
    @@prices[file_name] ||= []
  end

  def prepare_prices_data(artist_paragraphs)
    data = artist_paragraphs

    # First paragraph is always obligated to be an artist paragraph.
    # Artist name could be extracted easily. Paragraph will be skipped
    # in other child nodes.
    artist_name = data.shift.text.to_s

    # Artist paragraphs structure forces to create namespaces for each
    # record format.
    record_formats = data.slice_before do |paragraph|
      paragraph.attr('class') == SOURCE_CONFIG[file_name][:record_format_paragraph]
    end

    # Prices will be determined from investigating each record format namespace.
    record_formats.each_with_object([]) do |record_format_paragraphs, result|
      paragraphs = record_format_paragraphs

      # First paragraph is always obliged to be an 'record-format' paragraph.
      # Record format name will extracted easily then. Paragraph will be skipped
      # in other child nodes. Little hack need to be involved. To provide
      # correctly searching through existing prices encoded by nokogirii &:mdash
      # needs to be replaced by '-' (minus) character as it was in previous
      # parsing.

      rf_name_replacement = ->(text) {
        text.chars.inject("") { |r, chr| r << (chr.ord == 8211 ? "-" : chr); r }
      }
      record_format_name = rf_name_replacement.(paragraphs.shift.text)

      # Label, details, ranges and footnote will be extracted from each
      # record format children nodes.
      paragraphs.each do |paragraph|
        child_nodes = paragraph.children

        # Every price row has at least one 'tab-span' so we need to remove
        # invalid rows first
        next unless child_nodes.find {|node| node.attr('class') == 'Apple-tab-span'}

        # 'Tab-span' nodes could be easily used to create enclosed text namespaces
        child_nodes = child_nodes.slice_before do |node|
          node.attr('class') == 'Apple-tab-span'
        end

        child_nodes = Array(child_nodes)

        # Label and details extraction
        label_and_detail_extractor = ->(text) {
          detail = $2 if text =~ /(\()(.*)(\))/
          label = detail.present? ? text.gsub($1<<detail<<$3, '').strip : text.strip
          detail = detail.gsub(/[[:space:]]{2,}/, ' ') if detail.present?
          return [label, detail]
        }

        label_and_detail_nodes = child_nodes.shift
        label_and_detail_text = label_and_detail_nodes.inject([]) do |r, node|
          r << node.text; r
        end.join(' ')
        label, detail = label_and_detail_extractor.(label_and_detail_text)

        # Price range extraction
        price_range_extractor = ->(text) {
          text =~ /([0-9]*)-([0-9]*)(.*)/ and [$1, $2, $3]
        }

        price_range_nodes = child_nodes.shift
        price_range_text = price_range_nodes.inject('') do |r, node|
          r << node.text; r
        end if price_range_nodes.present?

        price_low, price_high, remaining_text =
          price_range_extractor.(price_range_text) if price_range_text.present?

        # Year range extraction
        year_range_extractor = ->(text) {
          if text =~ /(')([0-9]{1})[0-9]{1}(s)(.*)/
            year_begin, year_end = "19#{$2}0", "19#{$2}9"
            return [year_begin, year_end, $4]
          elsif text =~ /([0-9]{2})-([0-9]{2})(.*)/
            year_begin, year_end = "19#{$1}", "19#{$2}"
            return [year_begin, year_end, $3]
          elsif text =~ /([0-9]{4})(.*)/
            year_begin, year_end = $1, $1
            return [year_begin, year_end, $2]
          elsif text =~ /([0-9]{2})(.*)/
            year_begin, year_end = "19#{$1}", "19#{$1}"
            return [year_begin, year_end, $2]
          end
        }

        year_range_nodes = child_nodes.shift
        year_range_text = year_range_nodes.inject('') do |r, node|
          r << node.text; r
        end if year_range_nodes.present?

        year_begin, year_end, remaining_text =
          year_range_extractor.(year_range_text) if year_range_text.present?

        # Footnote extraction
        footnote_extractor = ->(text) { text =~ /(.*)/ and $1.gsub(/\(|\)/, '') }
        footnote = footnote_extractor.(remaining_text) if remaining_text.present?

        # Due to values discrepancies in our current database
        # we need to make sure that integer type attributes won't
        # be converted to 0 in case of nil value. They need to be compared
        # with nil.

        price_low &&= price_low.to_i
        price_high &&= price_high.to_i
        year_begin &&= year_begin.to_i
        year_end &&= year_end.to_i

        # Compose result price hash for future use.

        result << {
          'cached_artist' => artist_name,
          'media_type' => record_format_name,
          'cached_label' => label,
          'detail' => detail,
          'price_low' => price_low,
          'price_high' => price_high,
          'yearbegin' => year_begin,
          'yearend' => year_end,
          'footnote' => footnote
        }
      end
    end
  end

  def find_db_prices(artist, type, label)
    @raw_price_query = <<-SQL.strip
      SELECT prices.*
      FROM prices
      WHERE prices.cached_artist ILIKE ?
      AND prices.media_type ILIKE ?
      AND prices.cached_label ILIKE ?
    SQL

    query = ActiveRecord::Base.send(
      :sanitize_sql_array, [@raw_price_query, artist, type, label]
    )

    Price.select("*").from(Arel.sql("(#{query}) as prices"))
  end

  def fire_price_judgement!
    initialize_counters

    # There are a lot of parsed prices with missing detail attribute. We
    # need to make distinction between those two groups.

    prices_with_details, prices_without_detail = prices.partition do |price|
      price['detail'].present?
    end

    # We will start with analizing prices parsed without detail attribute

    prices_without_detail.each do |price|
      increment_total_with_missing_detail

      artist, type, label, detail, low, high, yearbegin, yearend = price.values

      db_prices = Array(find_db_prices(artist, type, label))

      if db_prices.present?
        # There is no need for invoking update-engine, if all attributes from
        # parsed price and database match. They will be rejected first.

        price_with_same_attributes = db_prices.find do |db_price|
          db_price.price_low == low && db_price.price_high == high &&
            db_price.yearbegin == yearbegin && db_price.yearend == yearend
        end

        if price_with_same_attributes.present?
          increment_price_with_same_attributes_and_missing_detail
        else
          increment_price_with_different_attributes_and_missing_detail
        end
      else
        increment_price_with_missing_detail_not_found
      end
    end
  end

  class << self
    def call
      SOURCE_FILES.each do |file_name|
        new(file_name).execute!
      end
    end
  end
end
