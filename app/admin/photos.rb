ActiveAdmin.register Photo do
  belongs_to :record
  
  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Photo", :multipart => true do
      f.input :title
      f.input :data
    end    
    f.buttons
  end
end
