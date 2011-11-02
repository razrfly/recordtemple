ActiveAdmin.register Song do
  belongs_to :record
  
  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs "Song", :multipart => true do
      #f.input :title
      f.input :mp3
    end    
    f.buttons
  end
  #form :partial => 'form'
end
