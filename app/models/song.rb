class Song < ActiveRecord::Base
  belongs_to :record
  attachment :audio

  Paperclip.interpolates :record_id  do |attachment, style|
    attachment.instance.record_id
  end

  has_attached_file :mp3,
    #:style => { :snippet => 'k128' },
    :storage => 's3',
    :s3_credentials => "#{Rails.root}/config/s3_credentials.yml",
    :bucket => 'recordtemple.com',
    :s3_host_alias => 'recordtemple.com.s3.amazonaws.com',
    :url => ':s3_alias_url',
    :path => "music/:record_id/:style/:basename.:extension",
    :s3_permissions => 'authenticated-read',
    :s3_protocol => 'http'

  def authenticated_url
    AWS::S3::S3Object.url_for(mp3.path, mp3.bucket_name, :expires_in => 10.minutes, :use_ssl => true).html_safe
  end

  protected

    def must_have_valid_artist_tag
      Mp3Info.open(mp3.to_file.path) do |mp3info|
        errors.add(:mp3, 'must not be a Michael Bolton song (what are you thinking?!)') if mp3info.tag.artist == 'Michael Bolton'
      end if mp3?
    rescue Mp3InfoError => e
      errors.add(:mp3, "unable to process file (#{e.message})")
    end

    def create_metadata
      Mp3Info.open(mp3.to_file.path) do |mp3info|
        if self.title.blank?
          self.title = mp3info.tag.title
          self.save
        end
      end
    end

end
