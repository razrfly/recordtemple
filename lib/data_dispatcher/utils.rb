module Utils
  EXECUTE_MESSAGE = {
    :load_file => 'Loading file... This could take a while.',
    :parse_file_with_nokogiri => 'Parsing file with nokogiri...',
    :fetch_allowed_paragraphs => 'Extracting allowed paragraphs from parsed file.',
    :extract_artists => 'Extract all artist related paragraphs.'
  }

  private

  def set_start_time
    @@start_time = Time.now
  end

  def execute_time
    @@execute_time ||= 0 and @@execute_time += (Time.now - @@start_time)
    puts "Done. Execution time: #@@execute_time"
  end

  def execute_message(command)
    puts EXECUTE_MESSAGE[command]
  end
end
