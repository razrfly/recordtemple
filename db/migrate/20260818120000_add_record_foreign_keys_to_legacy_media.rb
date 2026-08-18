class AddRecordForeignKeysToLegacyMedia < ActiveRecord::Migration[8.1]
  # Legacy Refile-era photos/songs rows had no FK to records, so destroying a
  # record silently stranded them (issue #385). `dependent: :destroy` on the
  # associations removes children first, so on_delete: :cascade never fires in
  # the normal path — it is the backstop for any delete_all-style bypass.
  def change
    add_foreign_key :photos, :records, on_delete: :cascade
    add_foreign_key :songs, :records, on_delete: :cascade
  end
end
