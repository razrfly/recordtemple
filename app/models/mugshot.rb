class Mugshot < ActiveRecord::Base
  belongs_to :record
  
  has_attachment :content_type => :image, 
                 :storage      => :file_system,
                 :path_prefix => 'public/mugshots', 
                 :max_size     => 1000.kilobytes,
                 :resize_to    => '1280x1024>',
                 :thumbnails   => { 
                   :large =>  '800x600>',
                   :medium => '400x300>',
                   :small =>  '100x100>' 
                 }

  validates_as_attachment
  
end
