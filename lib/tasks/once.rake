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
  
  
    
end

