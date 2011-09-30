class Song < ActiveRecord::Base
  belongs_to :record
  
  Paperclip.interpolates :record_id  do |attachment, style|
    attachment.instance.record_id
  end
  
  has_attached_file :mp3,
    #:style => { :snippet => 'k128' },
    :storage => 's3',
    :s3_credentials => "#{RAILS_ROOT}/config/s3_credentials.yml",
    :bucket => 'recordtemple.com',
    :s3_host_alias => 'recordtemple.com.s3.amazonaws.com',
    :url => ':s3_alias_url',
    :path => "music/:record_id/:style/:basename.:extension",
    :s3_permissions => 'authenticated-read',
    :s3_protocol => 'http'
    
  after_save :create_metadata#, :create_panda
  #after_destroy :remove_panda
    
  validates_attachment_presence :mp3
    #validates_attachment_content_type :mp3, :content_type => [ 'application/mp3', 'application/x-mp3', 'audio/mpeg', 'audio/mp3' ], :message => "requires a valid mp3 type"
  validates_attachment_size :mp3, :less_than => 10.megabytes
    
  validate :must_have_valid_artist_tag
  
  def authenticated_url(options={})
    #AWS::S3::S3Object.url_for(mp3.path(mp3.default_style), mp3.bucket_name, :expires_in => 10.minutes, :use_ssl => mp3.s3_protocol == 'https').html_safe
    options.reverse_merge! :expires_in => 10.minutes, :use_ssl => true
    AWS::S3::S3Object.url_for(mp3.path, mp3.options[:bucket], options).html_safe
  end
  
  def panda_url
    panda = Panda::Video.find(panda_id)
    unless panda.fail?
      panda.encodings.first.url
    else
      #panda.delete
      #recreate_panda
    end
  end

    protected
    
    def must_have_valid_artist_tag
      Mp3Info.open(mp3.to_file.path) do |mp3info|
        errors.add(:mp3, 'must not be a Michael Bolton song (what are you thinking?!)') if mp3info.tag.artist == 'Michael Bolton'
      end if mp3?
    rescue Mp3InfoError => e
      errors.add(:mp3, "unable to process file (#{e.message})")
    end
    
    def create_panda
      #video = Panda::Video.create(:source_url => mp3.url.gsub(/[?]\d*/,''), :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "music/#{record.id}/snippet/#{mp3_file_name.gsub('.mp3','')}")
      panda = Panda::Video.create(:source_url => authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{record.artist.id}/#{record.user_id}-#{record_id}-#{id}")
      self.panda_id = panda.id
      self.save
    end
    
    def recreate_panda
      panda = Panda::Video.create(:source_url => mp3.authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{mp3.record.artist.id}/#{mp3.record.user_id}-#{mp3.record_id}-#{mp3.id}")
      self.panda_id = panda.id
      self.save
    end
    
    def remove_panda
      unless panda_id.blank?
        panda = Panda::Video.find(panda_id)
        panda.delete
      end
    end
    
    def create_metadata
      Mp3Info.open(mp3.to_file.path) do |mp3info|
        if self.title.blank?
          self.title = mp3info.tag.title
          self.save
        end
        #open s3
        #track = AWS::S3::S3Object.find(mp3.path(:original), mp3.bucket_name)
        #mp3info.tag do |k,v|
        #  track.metadata["#{k}"] = "#{v}"
        #  track.store
        #end
      end
    end

end
