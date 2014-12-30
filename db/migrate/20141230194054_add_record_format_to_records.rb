class AddRecordFormatToRecords < ActiveRecord::Migration
  def up
    add_reference :records, :record_format, :index => true
    execute %q{UPDATE records SET record_format_id = (SELECT prices.record_format_id FROM prices WHERE prices.id = records.price_id)}
  end

  def down
    remove_reference :records, :record_format, :index => true
  end
end
