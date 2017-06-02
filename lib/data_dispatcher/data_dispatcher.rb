
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

    counter = Array(artists).count

    until counter.zero?
      prepare_prices_data(artists.next)
      counter -= 1
    end
    execute_time
  end

  private
  attr_reader :original_file, :parsed_file, :paragraphs, :artists

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

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
