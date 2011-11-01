ActiveAdmin.register Record do
  scope_to :current_user #unless proc{ current_user.admin? }
  #actions :index, :show#, :edit, :update
  menu :priority => 1
  
  
  controller do
    #autocomplete :artist, :name#, :full => true
    
    def new
      @record = Record.new(:price_id => params[:price_id], :user_id => current_user.id)
      # call `new!` to ensure that the rest of the action continues as normal
      new!
    end
  end
  
  scope :all, :default => true do |records|
    records.includes [:genre, :price]
  end
  #scope :LPs do |records|
  #  records.includes(:price).where(media_type.contains => 'LPs')
  #end
  scope :with_music
  scope :with_photo
  
  filter :cached_artist, :label => 'Artist'
  filter :cached_label, :label => 'Label'
  filter :comment
  filter :value, :label => 'My Value'
  #filter :price_pricelow, :as => :string, :label => 'Price Guide Value'
  filter :record_price_detail, :label => 'Detail'
  filter :price_detail_or_price_footnote, :as => :string, :label => 'Price Guide Detail'
  filter :price_media_type, :as => :select, :collection => RecordFormat.all.collect { |s| [s.name] }, :label => 'Format'
  filter :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }

  
  index do
    column("Image"){|record| image_tag record.cover_photo unless record.cover_photo.blank? }
    #column(:name){|space| link_to space.name, manage_space_path(space) }
    column 'Artist', :cached_artist
    column 'Label', :cached_label
    column :genre, :sortable => 'genres.name'
    #column("Media"){ |record| record.price.media_type }
    column 'Format', :record_format
    #column :notes, :sortable => false
    column :comment, :sortable => false
    column :updated_at
    default_actions
  end
  
  show do
    
    panel "Record Details" do
      attributes_table_for record do
        row :genre
        row :value
        row :comment
        row('Condition'){ record.the_condition }
        row :identifier_id
        row :created_at
        row :updated_at
        #row("Location"){ space.location.pretty_name }
        #row :email
        #row :phone
        #row :description
        #row("Blurb"){ markdown(space.blurb) }
      end
    end
    
    unless record.songs.blank?
      panel "Music" do
        #image_table_for(space.photos, "data")
        #attachment_table_for(space.photos)
      end
    end
    

  end
  
  form do |f|
    f.inputs "Details" do
      f.input :genre, :prompt => 'Please select'
      f.input :condition, :as => :select, :collection => Record::CONDITIONS.each_with_index.collect { |s, i| [s.titleize, i+1] }, :prompt => 'Please select'
      f.input :price_id, :as => :hidden
      f.input :user_id, :as => :hidden
      f.input :identifier_id, :as => :string
    end

    f.inputs "Freebase" do
      f.input :freebase_id, :input_html => { :class => "freebase_album" }
      f.input :freebase_id, :as => :hidden, :input_html => { :class => "freebase_album_id" }
    end
    
    f.inputs "Additional" do
      f.input :value, :as => :string
      f.input :comment
    end
    f.buttons

  end
  
  sidebar :price_guide, :only => [:new, :edit, :show] do
    attributes_table_for record.price do
      #row(:artist){ link_to record.artist.name, artist_path(record.artist), :class => 'artist' }
      #row(:artist){ auto_link(record.artist, :class => 'artist') }
      row :artist
      row("Artist Freebase ID"){ link_to record.artist.freebase_id, '#', :class => 'artist_freebase_id' }
      row :label
      row :record_format
      row :detail
      row :footnote
      row :price_range
      row :date_range
      row :freebase_id
      row("Last Updated"){ record.price.bubbles.last.created_at }
    end
  end
  
  sidebar :photos, :only => :show do
    
    table_for record.photos do# |photo|
      column("Photos"){ |photo| image_tag(photo.data.url(:thumb)) }
      #image_tag(photo.data.url)
    end
    #image_table_for(space.photos, "data")
    #attachment_table_for(space.photos)

  end
  
  #action_item :only => [:index, :show, :edit] do
  #  link_to "New Record", admin_prices_path
  #end
end
