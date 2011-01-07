namespace :fix do

    
  desc "Populate new artists table"
  task :artists => :environment do
    artists = Price.select('DISTINCT artist')
    artists.each do |artist|
      c = Artist.create(:name => artist.artist)
      puts c.name
      d = Price.find_all_by_artist(c.name)
      d.each do |r|
        r.artist_id = c.id
        r.save
      end
    end
  end
  
  desc "Populate new artists table"
  task :artists2 => :environment do
    Record.all.each do |record|
      record.artist_id = record.price.artist_id
      record.save
      puts record.price.artist
    end
  end
  
  desc "Populate new artists table"
  task :artists3 => :environment do
    Price.where("artist_id IS NULL").each do |record|
      artist = Artist.find_by_name(record.artist)
      record.artist_id = artist.id
      record.save(:validate => false)
      puts artist.name
    end
  end
  
  desc "Populate new artists table"
  task :artists4 => :environment do
    Record.where("artist_id IS NULL").each do |record|
      #artist = Artist.find_by_name(record.artist)
      record.artist_id = record.price.artist_id
      record.save!
      #record.artist_id = artist.id
      #record.save(:validate => false)
      #puts artist2#.name
    end
  end
  
  desc "Populate new artists table"
  task :genre => :environment do
    ["Rock 'n' Roll", "Surf", "Rockabilly", "Doo Wop", "Instrumental", "R&B", "Rock", "Country", "Easy Listening", "Jazz", "Northern Soul", "Pop", "Psychedelic/Garage", "Soul", "Soundtrack", "X-mas"].each do |genre|
      c = Genre.create(:name => genre)
    end
  end
  
  desc "Populate new artists table"
  task :freebase => :environment do
    Artist.where("freebase_tried IS NULL").order("id DESC").each do |record|
      coded = record.uncomma.gsub('&','and').gsub('#8211;','').gsub('#258;','').gsub('#','').gsub(';','')
      puts coded
      find = Artist.find_freebase(coded)
      #puts find
      if find and find.first
        puts find.first["id"]
        record.freebase_id = find.first["id"]
        
      end
      record.freebase_tried = TRUE
      record.save(:validate => FALSE)
      #record.artist.freebase_id = 
    end
  end
  
  desc "Populate new artists table"
  task :freebase2 => :environment do
    Record.select("DISTINCT artist_id").order("artist_id ASC").each do |record|
      if record.artist.freebase_id.blank? and record.artist.freebase_tried != TRUE
        coded = record.artist.uncomma.gsub('&','and').gsub('#8211;','')
        puts coded
        find = Artist.find_freebase(coded)
        
        theartist = Artist.find(record.artist)
        if find and find.first
          puts find.first["id"]
          
          theartist.freebase_id = find.first["id"]
          
          
        end
        theartist.freebase_tried = TRUE
        theartist.save
      end
      
      #record.artist.freebase_id = 
    end
  end  
  
  desc "Populate new artists table"
  task :snippets => :environment do
    Song.where("record_id > 7635").order("record_id").each do |rec|
      Mp3Info.open(rec.mp3.to_file.path) do |mp3info|
        puts mp3info.tag.title
        rec.title = mp3info.tag.title
        rec.save
        
        #do snippet
        video = Panda::Video.create(:source_url => rec.mp3.url.gsub(/[?]\d*/,''), :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "music/#{rec.record.id}/snippet/#{rec.mp3_file_name.gsub('.mp3','')}")
        puts rec.mp3.url.gsub(/[?]\d*/,'')
        puts "music/#{rec.record.id}/snippet/#{rec.mp3_file_name.gsub('.mp3','')}"
      end
    end
  end
  
  desc "Populate new artists table"
  task :snippets_specific => :environment do
    Song.where("record_id = 12851").order("record_id").each do |rec|       
      #do snippet
      video = Panda::Video.create(:source_url => URI::escape(rec.mp3.url.gsub(/[?]\d*/,'')), :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => URI::escape("music/#{rec.record.id}/snippet/#{rec.mp3_file_name.gsub('.mp3','')}"))
      puts URI::escape(rec.mp3.url.gsub(/[?]\d*/,''))
      puts URI::escape("music/#{rec.record.id}/snippet/#{rec.mp3_file_name.gsub('.mp3','')}")
      puts video.id
    end
  end
  
  desc "Populate new labels table"
  task :labels => :environment do
    #labels = Price.select('DISTINCT label')
    labels = Price.where("LENGTH(label) > 0").select("DISTINCT(label)")
    labels.each do |label|
      c = Label.create(:name => label.label)
      puts c.name
      d = Price.find_all_by_label(c.name)
      d.each do |r|
        r.label_id = c.id
        r.save!
      end
    end
  end
  
  desc "Populate new artists table"
  task :labels2 => :environment do
    Record.all.each do |record|
      
      #puts record.price.label
      
      if record.price.label_id
        record.label_id = record.price.label_id
        record.save!
      else
        puts record.id
      end
      
    end
  end
  
  desc "Populate new artists table"
  task :labels3 => :environment do
    Price.where("label_id IS NULL").each do |record|
      label = Label.find_by_name(record.label)
      record.label_id = label.id
      record.save(:validate => false)
      puts label.name
    end
  end
  
  desc "Populate new artists table"
  task :labels4 => :environment do
    Record.where("label_id IS NULL").each do |record|
      #artist = Artist.find_by_name(record.artist)
      record.label_id = record.price.label_id
      record.save!
      #record.artist_id = artist.id
      #record.save(:validate => false)
      #puts artist2#.name
    end
  end
  
  desc "Populate new artists table"
  task :freebase_labels => :environment do
    Label.where("freebase_tried IS NULL").order("id ASC").each do |label|
      begin
        find = Label.find_freebase(label.name.downcase)
      rescue
        puts "NO WAY"
      end
      puts label.name
      unless find.blank? # and find.first["id"]
        if find.first
          begin
            puts find.first["id"]
            label.freebase_id = find.first["id"]
          rescue
            puts "What the fuck?"
          end
        end
      end
      label.freebase_tried = TRUE
      label.save!
    end
  end
  
  desc "Populate new artists table"
  task :panda_del => :environment do
    Panda::Video.all.each do |video|
      puts video.original_filename
      video.delete
    end
  end
  
  desc "Populate new artists table"
  task :photo_dups => :environment do
    Photo.select('DISTINCT data_file_size record_id, record_id, COUNT(*)').group('data_file_size, record_id').order('COUNT DESC').each do |stuff|
      if stuff.count.to_i > 1
        #puts "Record #{stuff.record_id}"
        stuff.record.photos.select('DISTINCT data_file_name, MIN(id) AS photo_id').group('data_file_name').each do |photo|
          puts "#{photo.photo_id},"
          #Photo.find(photo.min).delete
        end
      end
    end
  end

  
  desc "Add record identifier"
  task :identify => :environment do
    Record.all.each do |r|
      #[\d]{2,}
      numbers = r.comment.scan(/[\d]{3,}[\s.]/)
      #puts numbers.size
      
      unless numbers.blank?
        if numbers.size == 1
          puts "record - #{r.id} - #{numbers[0].gsub(/[\D]/,'')} - #{r.comment}"
          r.identifier_id = numbers[0].gsub(/[\D]/,'')
          r.save!
        end
      end
    end
  end
  
  desc "Add record identifier"
  task :identify2 => :environment do
    Record.where("identifier_id IS NULL").each do |r|
      #[\d]{2,}
      numbers = r.price.detail.scan(/[\d]{1,}/)
      #puts numbers.size
      
      unless numbers.blank?
        if numbers.size == 1
          puts "record - #{r.id} - #{numbers[0].gsub(/[\D]/,'')} - #{r.price.detail}"
          r.identifier_id = numbers[0].gsub(/[\D]/,'')
          r.save!
        end
      end
    end
  end
  
  desc "Add record identifier"
  task :identify3 => :environment do
    Record.where("identifier_id IS NULL").each do |r|
      #[\d]{2,}
      numbers = r.comment.scan(/[\d.]{3,}/)
      #puts numbers.size
      
      unless numbers.blank?
        if numbers.size == 1
          puts "record - #{r.id} - #{numbers[0].gsub(/[\D]/,'')} - #{r.comment}"
          r.identifier_id = numbers[0].gsub(/[\D]/,'')
          r.save!
        end
      end
    end
  end
  
  desc "Populate new artists table"
  task :songs_g => :environment do
    Song.where("panda_id IS NULL").order("id DESC").limit(70).each do |mp3|
      puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
      panda = Panda::Video.create(:source_url => mp3.authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{mp3.record.artist.id}/#{mp3.record.user_id}-#{mp3.record_id}-#{mp3.id}")
      mp3.panda_id = panda.id
      puts panda.id
      mp3.save!
    end
  end
  
  desc "Populate new artists table"
  task :songs_g2 => :environment do
    Song.where("panda_id IS NULL").order("id DESC").limit(100).offset(650).each do |mp3|
      puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
      panda = Panda::Video.create(:source_url => mp3.authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{mp3.record.artist.id}/#{mp3.record.user_id}-#{mp3.record_id}-#{mp3.id}")
      mp3.panda_id = panda.id
      puts panda.id
      mp3.save!
    end
  end
  
  desc "Populate new artists table"
  task :songs_del => :environment do
    Song.where("panda_id IS NOT NULL").each do |mp3|
      #puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
      #c = Panda::Video.find(mp3.panda_id)
      #c.delete
    end
  end
  
  desc "Populate new artists table"
  task :songs_fail => :environment do
    Song.where("panda_id IS NOT NULL").each do |mp3|
      begin
        panda = Panda::Video.find(mp3.panda_id)
        if panda.fail?
          panda.delete
          puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
          panda = Panda::Video.create(:source_url => mp3.authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{mp3.record.artist.id}/#{mp3.record.user_id}-#{mp3.record_id}-#{mp3.id}")
          mp3.panda_id = panda.id
          puts panda.id
          mp3.save!
        end
      rescue
        puts "Failed!"
        puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
        panda = Panda::Video.create(:source_url => mp3.authenticated_url, :profiles => "f4475446032025d7216226ad8987f8e9", :path_format => "#{mp3.record.artist.id}/#{mp3.record.user_id}-#{mp3.record_id}-#{mp3.id}")
        mp3.panda_id = panda.id
        puts panda.id
        mp3.save!
      end
    end
  end
  
  desc "Populate new artists table"
  task :songs_fail2 => :environment do
    Song.where("panda_id IS NOT NULL").each do |mp3|
      panda = Panda::Video.find(mp3.panda_id)
      if panda.fail?
        puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
      end
      #puts "#{mp3.title} - with ID #{mp3.id} - Record #{mp3.record_id}"
      #c = Panda::Video.find(mp3.panda_id)
      #c.delete
    end
  end
  
  desc "Populate new artists table"
  task :cache_col => :environment do
    Record.all.each do |r|
      r.update_attribute :cached_artist, r.artist.name
      r.update_attribute :cached_label, r.label.name
    end
  end
    
end

