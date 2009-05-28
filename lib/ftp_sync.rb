require 'net/ftp'

module FtpSync
  
  # compares remote with local filelist
  # if local file not exists or older than remote file, download remote file
  # return array with new files
  def self.sync(config)
    new_files = Array.new
    
    # change local dir to save bnn-files correctly
    Dir.chdir("#{RAILS_ROOT}/#{config[:local_dir]}")
    
    # connect to ftp-server
    ftp = Net::FTP.new(config[:host], config[:user], config[:password])
    
    # loop over the remote filelist
    config[:filenames].each do |filename|
      # local file not exist or remote file newer ?
      if (File.exist?(filename) and File.new(filename).mtime < ftp.mtime(filename)) or !File.exist?(filename)
        # download
        ftp.getbinaryfile(filename)
      
        # save filename for return
        new_files << filename
      end
    end
    # close ftp-session
    ftp.close
    return new_files
  end
  
end