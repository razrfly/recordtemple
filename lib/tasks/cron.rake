task :cron => :environment do
     
  # backs up the database to S3
  puts "====> Backing up database to S3..."
  Rake::Task['db:backup'].invoke
  
end
