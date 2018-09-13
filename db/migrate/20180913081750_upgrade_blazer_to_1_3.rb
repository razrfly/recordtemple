class UpgradeBlazerTo13 < ActiveRecord::Migration
  def change
		add_column :blazer_dashboards, :creator_id, :integer
		add_column :blazer_checks, :creator_id, :integer
		add_column :blazer_checks, :invert, :boolean
		add_column :blazer_checks, :schedule, :string
		add_column :blazer_checks, :last_run_at, :timestamp
		commit_db_transaction

		Blazer::Check.update_all schedule: "1 hour"
  end
end
