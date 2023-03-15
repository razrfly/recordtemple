class RemoveDeviseCrud < ActiveRecord::Migration[7.0]
  def change
    # remove all devise columns
    remove_column :users, :confirmation_sent_at
    remove_column :users, :confirmation_token
    remove_column :users, :confirmed_at
    remove_column :users, :current_sign_in_at
    remove_column :users, :current_sign_in_ip
    remove_column :users, :encrypted_password
    remove_column :users, :fname
    remove_column :users, :lname
    remove_column :users, :last_sign_in_at
    remove_column :users, :last_sign_in_ip
    remove_column :users, :remember_created_at
    remove_column :users, :reset_password_sent_at
    remove_column :users, :reset_password_token
    remove_column :users, :sign_in_count
    remove_column :users, :unconfirmed_email
    remove_column :users, :password_salt
    remove_column :users, :invitation_accepted_at
    remove_column :users, :invitation_created_at
    remove_column :users, :invitation_limit
    remove_column :users, :invitation_sent_at
    remove_column :users, :invitation_token
    remove_column :users, :invited_by_id
    remove_column :users, :invited_by_type
    remove_column :users, :invitations_count
    remove_column :users, :slug
    remove_column :users, :avatar_id
    remove_column :users, :remember_token

  end
end
