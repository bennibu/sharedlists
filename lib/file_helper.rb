module FileHelper

  # return list of known file formats
  #   each file_format module has
  #   #name     returning a human-readable file format name
  #   #detect   returning a likelyhood (0-1) of being able to process
  #   #parse    parsing the data
  def self.file_formats
    {
      'foodsoft' => FoodsoftFile,
      'bnn' => BnnFile,
      'borkenstein' => Borkenstein,
      'dnb_xml' => DnbXmlFile,
      'dnb_csv' => DnbCsvFile,
      'terrasana' => TerrasanaFile,
      'bdtotaal' => BdtotaalFile,
      'wimbijma' => WimbijmaCsvFile,
      'vriesia' => VriesiaFile,
    }
  end

  # detect file format
  def self.detect(file, opts={})
    file.set_encoding(opts[:encoding]) unless opts[:encoding].blank?
    formats = file_formats.values.map {|f| file.rewind; [f, f::detect(file, opts)]}
    formats.sort_by! {|f| f[1]}
    file.rewind
    formats.last[1] < 0.5 and raise Exception.new("Could not detect file-format, please select one.")
    formats.last[0]
  end

  # parse file by type (one of #file_formats, or 'auto')
  def self.parse(file, opts={}, &blk)
    file.set_encoding(opts[:encoding]) unless opts[:encoding].blank?
    parser = ( (opts[:type].nil? or opts[:type]=='auto') ? detect(file, opts) : file_formats[opts[:type]])
    # TODO handle wrong or undetected type
    parser::parse(file, opts, &blk)
  end

  # return most probable column separator character from first line
  def self.csv_guess_col_sep(file)
    seps = [",", ";", "\t", "|"]
    position = file.tell
    firstline = file.readline
    file.seek(position)
    seps.map {|x| [firstline.count(x),x]}.sort_by {|x| -x[0]}[0][1]
  end

  # read file until start of regexp
  def self.skip_until(file, regexp)
    begin
      file.eof? and return nil
      position = file.tell
      line = file.readline
    end until line.match regexp
    file.seek(position)
    file
  end

end
