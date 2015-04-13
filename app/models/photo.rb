class Photo < ActiveRecord::Base
  belongs_to :record
  attachment :image

  # Paperclip.interpolates :record_id  do |attachment, style|
  #   attachment.instance.record_id
  # end

  # has_attached_file :data,
  #   :storage => 's3',
  #   :s3_credentials => "#{Rails.root}/config/s3_credentials.yml",
  #   :bucket => 'recordtemple.com',
  #   :s3_host_alias => 'recordtemple.com.s3.amazonaws.com',
  #   :url => ':s3_alias_url',
  #   :path => "images/records/:record_id/:style/:basename.:extension",  
  #   :styles => { :thumb => "60x60#", :small => "200x200#", :medium => "400x400#", :large => "800x800#" },   
  #   :default_style => :original,
  #   :default_url => 'http://recordtemple.com.s3.amazonaws.com/images/records/m1.png',
  #   :s3_headers => { 'Expires' => 2.months.from_now.httpdate },
  #   :convert_options => { :all => '-strip -trim' }

    # validates_attachment_presence :data
    # validates_attachment_size :data, :less_than => 5.megabytes
    #validates_attachment_content_type :data, :content_type => ['image/jpeg','image/gif','image/png']
end
