class DataDispatcher
  include Utils

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
    allowed_paragraphs = %w(p2 p3 p4)

    @paragraphs = Array(parsed_file.css('p')).keep_if do |paragraph|
      allowed_paragraphs.include? paragraph.attr('class')
    end
    execute_time
  end

  def create_artists_namespaces
    execute_message(__callee__)

    @artists = paragraphs.slice_before do |paragraph|
      paragraph.attr('class') == 'p2'
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
      end
    end
  end

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
