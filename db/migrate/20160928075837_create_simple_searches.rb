class CreateSimpleSearches < ActiveRecord::Migration
  def change
    create_view :simple_searches
  end
end
