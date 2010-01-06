namespace :db do
    
desc "Backs up the database to S3"
  task :backup => :environment do
     
    puts "Back up started on #{Time.now}..."
    APP_NAME = 'recordapp'
    BACKUP_BUCKET = 'recordtemple.com'
    PATH_TO_CLIENT_BACKUP = '/backup'

    puts "Pulling database..."
    backup_name =  "ew#{Time.now.to_i}.db"
    backup_path = "tmp/#{backup_name}"
    YamlDb.dump backup_path

    puts "Compressing database..."
    `gzip #{backup_path}`
    backup_name += ".gz"
    backup_path = "tmp/#{backup_name}"

    puts "Uploading #{backup_name} to S3..."

    puts "Connecting to AWS..."
    config = YAML.load(File.open("#{RAILS_ROOT}/config/s3_credentials.yml"))[RAILS_ENV]
    AWS::S3::Base.establish_connection!(
      :access_key_id     => config['access_key_id'],
      :secret_access_key => config['secret_access_key']
    )

    puts "Finding S3 bucket..."
    begin
      bucket = AWS::S3::Bucket.find config['bucket']
    rescue AWS::S3::NoSuchBucket
      AWS::S3::Bucket.create config['bucket']
      bucket = AWS::S3::Bucket.find config['bucket']
    end

    puts "Storing backup database on S3..."
    AWS::S3::S3Object.store backup_name, 
       File.read(backup_path), 
       bucket.name + PATH_TO_CLIENT_BACKUP, 
       :content_type => 'application/x-gzip'

    puts "Backup ended on #{Time.now}"
    `rm #{backup_path}`
     
  end
   
end