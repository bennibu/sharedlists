# Module for Wim Bijma CSV import
 
require 'csv'

module WimbijmaCsvFile

  def self.name
    "Wim Bijma (CSV)"
  end

  def self.detect(data)
    # when there's line with just the firm name
    sep = FileHelper::csv_guess_col_sep(data[0..200])
    data[0..200].match(/(^|\n)(\s*#{sep})*\s*MAATSCHAP\s+BIJMA-MEEKEL/mi) ? 0.9 : 0
  end
  
  # the parsed article is a simple hash
  def self.parse(data)
    category = [nil, nil]
    data.gsub! /^.*?\n\s*(Aantal)/m, '\1' # first couple of lines may be a header
    rowschecked = false
    CSV.parse(data, {:col_sep => FileHelper.csv_guess_col_sep(data), :headers => true}) do |row|
      # we can't use header names since they're used twice (two columns)
      unless rowschecked
        check_header(row.headers[0..3], "first column")
        check_header(row.headers[5..8], "second column")
        rowschecked = true
      end

      # categories take their own line
      if not row[1].blank? and row[2].blank? and row[3].blank?
        category[0] = row[1]
        next
      end
      if not row[5].blank? and row[6].blank? and row[7].blank?
        category[1] = row[2]
        next
      end

      row[2] and yield parse_article(row[1], row[2], row[3], category[0]), nil
      row[6] and yield parse_article(row[6], row[7], row[8], category[1]), nil
    end
  end

  protected

  def self.check_header(cols, name=nil)
    unless cols[0].match /Aantal/ and
      cols[1].match /Per/ and
      cols[2].match /Produktnaam/ and
      cols[3].match /Prijs/
        raise Exception("Unexpected header" + (name.nil? ? '' : " (#{name})}"))
    end
  end

  def self.parse_article(unit, name, price, category)
    article = {:number => name,
               :name => name,
               :note => nil,
               :manufacturer => nil,
               :origin => 'nld',
               :unit => unit,
               :price => price,
               :unit_quantity => 1,
               :tax => 6,
               :deposit => 0,
               :category => category}
  end
    
end
