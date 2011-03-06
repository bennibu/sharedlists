desc "Sync bnn files with remote ftp connection. Update articles."
task :sync_bnn_files => :environment do
  Supplier.bnn_sync.all.each do |supplier|
    puts "Sync bnn files for #{supplier.name}..."
    supplier.sync_bnn_files
  end
end