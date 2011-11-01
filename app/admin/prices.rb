ActiveAdmin.register Price do
  menu :label => "Price Guide"
  #has_many :records
  
  #scope :all, :default => true do |records|
  #  records.includes [:artist, :label]
  #end
  
  #"","Singles","LPs","EPs","Picture Sleeves"
  scope :all
  #scope :lps do |media|
  #  media.where(:media_type.contains => 'LPs')
  #end
  
  filter :cache_artist, :label => 'Artist'
  filter :cache_label, :label => 'Label'
  filter :record_format
  filter :detail
  filter :pricelow
  filter :pricehigh


  #filter :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }
  
  index do
    #column("Image"){|record| image_tag record.cover_photo unless record.cover_photo.blank? }
    #column(:name){|space| link_to space.name, manage_space_path(space) }
    column 'Artist', :cache_artist#, :sortable => 'cache_artist'
    column 'Label', :cache_label#, :sortable => false#, :sortable => 'cache_label'
    column :detail, :sortable => false
    column :media_type
    #default_actions
    column() do |price|
      a 'Show', :href => admin_price_path(price)
      a 'Create', :href => new_admin_record_path
    end
  end
end
