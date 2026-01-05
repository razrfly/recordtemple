# Upgrade passwordless from 0.x to 1.x
# See: https://github.com/mikker/passwordless/blob/master/CHANGELOG.md
class AddIdentifierToPasswordlessSessions < ActiveRecord::Migration[8.1]
  def change
    # Add identifier column (v1.x uses this instead of primary key for URLs)
    add_column :passwordless_sessions, :identifier, :string
    add_index :passwordless_sessions, :identifier, unique: true

    # Make PII columns nullable (v1.x no longer collects this data)
    change_column_null :passwordless_sessions, :user_agent, true
    change_column_null :passwordless_sessions, :remote_addr, true
  end
end
