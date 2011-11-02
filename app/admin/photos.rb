ActiveAdmin.register Photo do
  belongs_to :record
  
  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Photo", :multipart => true do
      f.input :title
      f.input :data
    end    
    f.buttons
  end
  
  sidebar :thumb, :only => [:edit, :show] do
    attributes_table_for photo do
      image_tag photo.data.url(:medium), :width => '250'
    end
  end
end
