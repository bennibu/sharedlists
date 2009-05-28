
# parses bnn files and imports article
def import_files(filenames, supplier_id)
  # load terra-object
  supplier = Supplier.find(supplier_id)
  
  puts "parses files and imports articles ..."
  filenames.each do |file|
    puts "parse #{file}..."
    outlisted_counter, new_counter, updated_counter, invalid_articles = 
          supplier.update_articles_from_file(File.open("#{RAILS_ROOT}/tmp/#{file}", "r").read, 'bnn', file, '850')
    puts "Summary for #{file}:"
    puts "new: #{new_counter}"
    puts "updated: #{updated_counter}"
    puts "outlisted: #{outlisted_counter}"
    puts "invalid: #{invalid_articles.size}"
  end
  
  puts "missing bnn-codes:"
  $missing_bnn_codes.uniq.sort.each {|code| puts code }
end

namespace :terra do
  
  desc "parse all terra files in RAILS_ROOT/tmp/. imports the articles"
  task :import_all => :environment do
    Dir.chdir("#{RAILS_ROOT}/tmp/")
    
    puts "parses and imports articles"
    import_files(Dir["*.BNN"], 1)
    
    puts "import_all finished"
  end
  
  # "rake sharedLists:sync_terra"
  desc "sync local bnn-files with terra-ftp server and updates database"
  task :ftp_sync => :environment do
    
    # load sync-library
    require 'ftp_sync'
    
    # load configuration for ftp-sync
    require 'yaml'
    config = YAML::load(File.open("#{RAILS_ROOT}/config/terra.yml")).symbolize_keys
    
    puts "sync bnn-files with ftp-server ..."
    new_files = FtpSync::sync(config)
    
    unless new_files.empty?
      puts "new downloaded files: #{new_files.join(', ')}"
      # parses and import articles now      
      import_files(new_files)   
    else
      puts "no new files"
    end
    puts "ftp_sync is finished"
  end
  
end

namespace :midgard do
  desc "parse all midgard files in #{RAILS_ROOT}/tmp/. import the articles"
  task :import_all => :environment do
    Dir.chdir("#{RAILS_ROOT}/tmp/")
    
    puts "parse and import articles"
    import_files(Dir["*.BNN"], 3)
    
    
    puts "import is finished"
  end
end