class AddDiscogsSkipFieldsToRecords < ActiveRecord::Migration[8.1]
  def change
    add_column :records, :discogs_skip_review, :boolean
    add_column :records, :discogs_skip_reason, :string
  end
end
