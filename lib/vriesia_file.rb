# Module for import of Vriesia products from their Excel sheet
# Please export the excel sheet as CSV, and import that.

require 'csv'

module VriesiaFile

  def self.name
    "Vriesia (CSV)"
  end

  def self.detect(file, opts={})
    firstline = file.readline
    somefields = [/Artnr/, /V/, /Omschrijving/, /Inhoud/, /CAP/, /detail/, /OVV/, /BTW/, /EAN code/]
    somefields.select{|re| firstline.match re}.count / somefields.count
  end

  def self.parse(file, opts={})
    CSV.new(file, {:col_sep => FileHelper.csv_guess_col_sep(file), :headers => true}).each do |row|
      # create a new article
      unit = row['Inhoud'] and unit = unit.downcase
      name = proper_name(row['Omschrijving'])
      tax = row['BTW']
      tax == 'L' and tax = 6
      tax == 'H' and tax = 21
      article = {:number => row['Artnr.'],
                 #:ean => row['EAN code'],
                 :name => name,
                 #:note => nil,
                 #:manufacturer => nil,
                 #:origin => nil,
                 :unit => unit,
                 :price => row['detail'],
                 :unit_quantity => row['OVV'],
                 :tax => tax,
                 :deposit => 0,
                 #:category => nil
                 }
      # outlisting not used by supplier
      yield article, (row['status']=='x' ? :outlisted : nil)
    end
  end

  protected
  # cleanup name, which is given in all capitals
  def self.proper_name(name)
    name.nil? and return nil
    name = name.humanize
    # now some abbreviations would be nice to have capitalized
    [
      # single letters, optionally combined with numbers
      /\b([0-9]+)?[a-z]([0-9]+)?\b/i,
      # brands
      /\bFA\b/i, /\bHG\b/i, /\bHMK\b/i, /\bJH\b/i, /\bOB\b/i, /\bVSM\b/i, /\bZW\b/i,
      /\bAS\b/i, /\bSCD\b/i, /\bSCF\b/i,
      # other abbreviations
      /\bX+L\b/i, /\bWC\b/i, /\bI+\b/i,
    ].each do |re|
      name.gsub!(re) {|s| s.upcase}
    end
    # and then turn some back
    [/t\.pasta/i, /z\.wit/i, /-o-/i, /a\.tand/i].each do |re|
      name.gsub!(re) {|s| s.downcase}
    end

    name
  end

end
