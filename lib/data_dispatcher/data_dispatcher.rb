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

    artists.each do |artist|
      prepare_prices_data(artist).each do |data|
        prices << data
      end
    end

    execute_time
  end

  private
  attr_reader :original_file, :parsed_file, :paragraphs, :artists, :prices

  def create_file_path
    @file_path = Rails.root.join('lib', 'data_dispatcher', @file_name)
  end

  def load_file
    execute_message(__callee__)

    File.exist?(@file_path) && @original_file = open(@file_path)
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
    @prices ||= []
  end

  def prepare_prices_data(artist_paragraphs)
    data = artist_paragraphs

    # First paragraph is always obligated to be an artist paragraph.
    # Artist name could be extracted easily. Paragraph will be skipped
    # in other child nodes.
    artist_name = data.shift.text

    # Artist paragraphs structure forces to create namespaces for each
    # record format.
    record_formats = data.slice_before do |paragraph|
      paragraph.attr('class') == 'p3'
    end

    # Prices will be determined from investigating each record format namespace.
    record_formats.each_with_object([]) do |record_format_paragraphs, result|
      paragraphs = record_format_paragraphs

      # First paragraph is always obliged to be an record format paragraph.
      # Record format name could be extracted easily. Paragraph will be skipped
      # in other child nodes.
      record_format_name = paragraphs.shift.text

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
        label_and_details_extractor = ->(text) {
          details = $2 if text =~ /(\()(.*)(\))/
          label = details.present? ? text.gsub($1<<details<<$3, '').strip : text
          return [label, details]
        }

        label_and_details_nodes = child_nodes.shift
        label_and_details_text = label_and_details_nodes.inject('') do |r, node|
          r << node.text; r
        end

        label, details = label_and_details_extractor.(label_and_details_text)

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

        # Compose result price hash for future use.
        result << {
          cached_artist: artist_name,
          media_type: record_format_name,
          cached_label: label,
          details: details,
          price_low: price_low,
          price_high: price_high,
          yearbegin: year_begin,
          yearend: year_end,
          footnote: footnote
        }
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
