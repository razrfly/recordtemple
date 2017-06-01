class DataDispatcher
  def initialize(file_name)
    @file_name = file_name
  end

  def execute!
    create_file_path
    load_file
  end

  private
  attr_reader :original_file

  def create_file_path
    @file_path = Rails.root.join('lib', 'data_dispatcher', @file_name)
  end

  def load_file
    File.exist?(@file_path) && @original_file = open(@file_path)
  end

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
