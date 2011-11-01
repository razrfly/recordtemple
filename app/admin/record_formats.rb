ActiveAdmin.register RecordFormat do
  index do
    id_column
    column :name
    #column('count'){ |record_format| record_format.prices.size.to_i }
    default_actions
  end
end
