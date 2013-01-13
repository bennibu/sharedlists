
# parses bnn files and imports article
def import_files(filenames, supplier_name, options = {})

  options[:format] ||= 'bnn'
  options[:encoding] ||= '850'

  # load terra-object
  supplier = Supplier.find_by_name(supplier_name)
  raise "Can't find Supplier #{supplier_name}!" if supplier.nil?
  
  puts "parses files and imports articles ..."
  filenames.each do |file|
    puts "parse #{file}..."
    outlisted_counter, new_counter, updated_counter, invalid_articles = 
          supplier.update_articles_from_file(File.open("#{Rails.root}/tmp/#{file}", "r").read, options[:format], options[:encoding])
    puts "Summary for #{file}:"
    puts "new: #{new_counter}"
    puts "updated: #{updated_counter}"
    puts "outlisted: #{outlisted_counter}"
    puts "invalid: #{invalid_articles.size}"
  end

  if $missing_bnn_codes
    puts "missing bnn-codes:"
    $missing_bnn_codes.uniq.sort.each {|code| puts code }
  end
end

namespace :terra do
  
  desc "parse all terra files in Rails.root/tmp/. imports the articles"
  task :import_all => :environment do
    Dir.chdir("#{Rails.root}/tmp/")
    
    puts "parses and imports articles"
    import_files(Dir["*.BNN"], "Terra Naturkost Handels KG")
    
    puts "import_all finished"
  end
  
  # "rake sharedLists:sync_terra"
  desc "sync local bnn-files with terra-ftp server and updates database"
  task :ftp_sync => :environment do
    
    # load sync-library
    require 'ftp_sync'
    
    # load configuration for ftp-sync
    require 'yaml'
    config = YAML::load(File.open("#{Rails.root}/config/terra.yml")).symbolize_keys
    
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
  desc "parse all midgard files in #{Rails.root}/tmp/. import the articles"
  task :import_all => :environment do
    Dir.chdir("#{Rails.root}/tmp/")
    
    puts "parse and import articles"
    import_files(Dir["*.BNN"], "Midgard")
    
    
    puts "import is finished"
  end
end

namespace :borkenstein do
  desc "parse all midgard files in #{Rails.root}/tmp/. import the articles"
  task :import_all => :environment do
    Dir.chdir("#{Rails.root}/tmp/")

    puts "parse and import articles"
    import_files(Dir["*3.1.CSV"], "Borkenstein", :format => 'borkenstein', :encoding => 'LATIN1')
    
    puts "import is finished"
  end
  
end