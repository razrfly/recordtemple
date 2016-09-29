class SimpleSearch < ActiveRecord::Base
  belongs_to :searchable, :polymorphic => true

  def self.new(query)
    return [] if query.empty?
    self.fuzzy_search(query).preload(:searchable)
  end

  def readonly?; true; end
 end
