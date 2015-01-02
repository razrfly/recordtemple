class AddLabelToRecordsAgain < ActiveRecord::Migration
  def up
    add_reference :records, :label, :index => true
    execute %q{UPDATE records SET label_id = (SELECT prices.label_id FROM prices WHERE prices.id = records.price_id)}
  end

  def down
    remove_reference :records, :label, :index => true
  end
end
