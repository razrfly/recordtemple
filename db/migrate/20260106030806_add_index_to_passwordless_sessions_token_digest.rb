class AddIndexToPasswordlessSessionsTokenDigest < ActiveRecord::Migration[8.1]
  def change
    add_index :passwordless_sessions, :token_digest, unique: true
  end
end
