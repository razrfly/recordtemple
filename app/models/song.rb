class Song < ActiveRecord::Base
  belongs_to :record
  
  Paperclip.interpolates :record_id  do |attachment, style|
    attachment.instance.record_id
  end
  
  has_attached_file :mp3,
    :storage => 's3',
    :s3_credentials => "#{RAILS_ROOT}/config/s3_credentials.yml",
    :bucket => 'recordtemple.com',
    :s3_host_alias => 'recordtemple.com.s3.amazonaws.com',
    :url => ':s3_alias_url',
    :path => "music/:record_id/:style/:basename.:extension"
    
    validates_attachment_presence :mp3
    #validates_attachment_content_type :mp3, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ], :message => "requires a valid mp3 type"
    validates_attachment_size :mp3, :less_than => 10.megabytes
    
    validate :must_have_valid_artist_tag

    protected

    def must_have_valid_artist_tag
      Mp3Info.open(mp3.to_file.path) do |mp3info|
        errors.add(:mp3, 'must not be a Michael Bolton song (what are you thinking?!)') if mp3info.tag.artist == 'Michael Bolton'
      end if mp3?
    rescue Mp3InfoError => e
      errors.add(:mp3, "unable to process file (#{e.message})")
    end
end
