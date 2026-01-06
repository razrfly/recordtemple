class AddTokenDigestToPasswordlessSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :passwordless_sessions, :token_digest, :string
    remove_column :passwordless_sessions, :token, :string
    # Clear existing sessions since they won't work with new schema
    Passwordless::Session.delete_all
  end
end
