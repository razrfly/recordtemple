class Freebase
  def self.find(freebase_id)
    Ken::Topic.get(freebase_id)
  end
end