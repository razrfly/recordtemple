class DataDispatcher
  def initialize(file_name)
    @file_name = file_name
  end

  def execute!
    create_file_path
  end

  private

  def create_file_path
    @file_path = Rails.root.join('lib', 'data_dispatcher', @file_name)
  end

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
