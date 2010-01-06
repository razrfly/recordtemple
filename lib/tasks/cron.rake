task :cron => :environment do
     
  # run the following tasks on sunday
  if Time.now.hour == 0
     
    # backs up the database to S3
    puts "====> Backing up database to S3..."
    Rake::Task['db:backup'].invoke
  
  end
   
end
