class DataDispatcher
  EXECUTE_MESSAGE = {
    :load_file => 'Loading file... This could take a while.',
    :parse_file_with_nokogiri => 'Parsing file with nokogiri...'
  }

  def initialize(file_name)
    @file_name = file_name
  end

  def execute!
    set_start_time
    create_file_path
    load_file
    parse_file_with_nokogiri
  end

  private
  attr_reader :original_file, :parsed_file

  def set_start_time
    @start_time = Time.now
  end

  def execute_time
    @execute_time ||= 0 and @execute_time += (Time.now - @start_time)
    puts "Done. Execution time: #@execute_time"
  end

  def execute_message(command)
    puts EXECUTE_MESSAGE[command]
  end

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

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
