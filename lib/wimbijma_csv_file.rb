# Module for Wim Bijma CSV import
 
require 'csv'

module WimbijmaCsvFile

  def self.name
    "Wim Bijma (CSV)"
  end

  def self.detect(file, opts={})
    # when there's line starting with the firm name
    sep = FileHelper.csv_guess_col_sep(file)
    FileHelper.skip_until(file, /(\s*#{sep})*\s*MAATSCHAP\s+BIJMA-MEEKEL/i).nil? ? 0 : 0.9
  end
  
  # the parsed article is a simple hash
  def self.parse(file, opts={})
    category = [nil, nil]
    col_sep = FileHelper.csv_guess_col_sep(file)
    FileHelper.skip_until file, /^\s*Aantal/
    CSV.new(file, {:col_sep => col_sep, :headers => true, :return_headers => true}).each do |row|
      # we can't use header names since they're used twice (two columns); do check them
      if row.header_row?
        check_header([row[0],row[1],row[2],row[3]], "first column")
        check_header([row[5],row[6],row[7],row[8]], "second column")
        next
      end

      # categories take their own line
      if not row[0].blank? and row[1].blank? and row[2].blank? and row[3].blank?
        category[0] = row[0]
        next
      end
      if not row[5].blank? and row[6].blank? and row[7].blank? and row[8].blank?
        category[1] = row[5]
        next
      end

      row[2] and yield parse_article(row[1], row[2], row[3], category[0]), nil
      row[7] and yield parse_article(row[6], row[7], row[8], category[1]), nil
    end
  end

  protected

  def self.check_header(cols, name=nil)
    unless not cols[0].blank? and cols[0].match /Aantal/ and
      not cols[1].blank? and cols[1].match /Per/ and
      not cols[2].blank? and cols[2].match /Produktnaam/ and
      not cols[3].blank? and cols[3].match /Prijs/
        raise Exception.new("Unexpected header" + (name.nil? ? '' : " (#{name})}"))
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
