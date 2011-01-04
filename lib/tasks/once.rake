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
  
    
end

