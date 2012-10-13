require 'net/ftp'
require 'fileutils'

module FtpSync
  
  # compares remote with local filelist
  # if local file not exists or older than remote file, download remote file
  # return array with new files
  def self.sync(supplier)
    new_files = Array.new
    
    # change local dir to save bnn-files correctly
    FileUtils.mkdir_p(supplier.bnn_path) unless File.exists?(supplier.bnn_path)
    Dir.chdir(supplier.bnn_path)
    
    # connect to ftp-server
    ftp = Net::FTP.new(supplier.bnn_host, supplier.bnn_user, supplier.bnn_password)
    
    # loop over the remote filelist
    ftp.nlst.each do |filename|
      # File is an bnn article list? All BNN Files have filenames beginning with PL
      if filename.match(/^(\.\/)?PL/)
        # local file not exist or remote file newer ?
        if (File.exist?(filename) and File.new(filename).mtime < ftp.mtime(filename)) or !File.exist?(filename)
          # download
          ftp.getbinaryfile(filename)
          # save filename for return
          new_files << filename
        end
      end
    end
    # close ftp-session
    ftp.close
    return new_files
  end
  
end