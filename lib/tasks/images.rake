namespace :images do
  desc "migrate to refile"
  task :migrate_to_refile => :environment do
    Photo.where(:image_id => nil).find_each do |photo|
      print "Processing photo ##{photo.id}..."
      begin
        open(photo.data(:original), 'rb') { |file| photo.image = file; photo.save }
      rescue
        next
      end
      puts " Done!"
    end
  end

  desc "fill image_content_type"
  task :migrate_content_type => :environment do
    Photo.find_each do |photo|
      photo.update_column(:image_content_type, 'image/jpeg')
    end
    puts " Done!"
  end

  desc "copy image size to db"
  task :copy_size => :environment do
    print "Processing image "
    Photo.find_each do |photo|
      print "IMAGE ##{photo.id} "
      begin
        photo.update_column(:image_size, photo.image.size)
        puts 'OK'
      rescue
        puts 'FAILED!'
      end
    end
    puts " Done!"
  end

  desc "copy file_name"
  task :copy_filename => :environment do
    Photo.find_each do |photo|
      photo.update_column(:image_filename, photo.data_file_name)
    end
    puts " Done!"
  end

end