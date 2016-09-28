class DropOldSearchDatabaseView < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute <<-SQL
      DROP VIEW searches;
    SQL
  end
end
