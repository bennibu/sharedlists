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
    }
  end

  # detect file format
  def self.detect(data)
    formats = file_formats.values
    formats.sort_by! {|f| f::detect(data)}
    formats.last
  end

  # parse file by type (one of #file_formats, or 'auto')
  def self.parse(data, type='auto', &blk)
    parser = (type == 'auto' ?  detect(data) : file_formats[type])
    # TODO handle wrong or undetected type
    parser::parse(data, &blk)
  end

  # return most probable column separator character from first line
  def self.csv_guess_col_sep(data)
    seps = [",", ";", "\t", "|"]
    firstline = data[0..(data.index("\n")||-1)]
    seps.map {|x| [firstline.count(x),x]}.sort_by {|x| -x[0]}[0][1]
  end

end
