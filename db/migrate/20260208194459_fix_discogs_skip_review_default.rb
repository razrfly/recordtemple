class FixDiscogsSkipReviewDefault < ActiveRecord::Migration[8.1]
  def up
    # Set default value for the column
    change_column_default :records, :discogs_skip_review, from: nil, to: false

    # Backfill existing NULL values
    Record.reset_column_information
    Record.where(discogs_skip_review: nil).update_all(discogs_skip_review: false)

    # Add NOT NULL constraint
    change_column_null :records, :discogs_skip_review, false
  end

  def down
    change_column_null :records, :discogs_skip_review, true
    change_column_default :records, :discogs_skip_review, from: false, to: nil
  end
end
