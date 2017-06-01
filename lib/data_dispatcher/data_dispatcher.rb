class DataDispatcher
  def initialize(file_name)
    @file_name = file_name
  end

  class << self
    def call(file_name)
      new(file_name).execute!
    end
  end
end
