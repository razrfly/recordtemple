ActiveAdmin.register Price do
  menu :label => "Price Guide", :priority => 2
  
  #scope :all, :default => true
  
  scope :all, :default => true do |prices|
    prices.includes [:bubbles]
  end

  
  filter :cached_artist, :label => 'Artist'
  filter :cached_label, :label => 'Label'
  filter :detail_or_footnote, :as => :string, :label => 'Comments'
  filter :record_format
  filter :pricelow
  filter :pricehigh


  #filter :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }
  
  index do
    id_column
    column 'Artist', :cached_artist#, :sortable => 'cached_artist'
    column 'Label', :cached_label#, :sortable => false#, :sortable => 'cached_label'
    column :detail, :sortable => false
    column :media_type
    column :top_price

    #default_actions
    column() do |price|
      a 'Show', :href => admin_price_path(price)
      a 'Edit', :href => edit_admin_price_path(price)
      a 'Create', :href => new_admin_record_path(:price_id => price)
    end
  end
  
  form :partial => "form"
  
end
