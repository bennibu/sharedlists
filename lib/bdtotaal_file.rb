# Module for BD-Totaal CSV import
 
require 'csv'

module BdtotaalFile

  def self.name
    "BD-Totaal (CSV)"
  end

  def self.detect(data)
    # when there is a line starting with BD-Totaal
    data[0..200].match(/\n\s*(,\s*)*BD-Totaal/m) ? 0.9 : 0
  end
  
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(data)
    data.gsub! /^.*?\n\s*(Artikelcode)/m, '\1' # first couple of lines may be a header
    articles, outlisted_articles = Array.new, Array.new
    headclean = Proc.new {|x| x.gsub /^\s*(.*?)\s*$/, '\1'} # remove whitespace around headers
    CSV.parse(data, {:col_sep => FileHelper.csv_guess_col_sep(data), :headers => true, :header_converters => headclean}) do |row|
      # skip empty lines
      row[0].blank? and next
      # create a new article
      name = row['Artikelomschrijving']
      manuf = row['Merknaam']
      if not manuf.blank? and manuf.match /(verpakt|los)/
        name += " (#{manuf})"
        manuf = nil
      end
      unit_price = parse_price(row['Eenheidsprijs'])
      pack_price = parse_price(row['Colloprijs'])
      unit, unit_quantity = parse_inhoud(row['Inhoud'], unit_price, pack_price)
      article = {:number => row['Artikelcode'],
                 :name => name,
                 :note => row['Kwaliteit'],
                 :manufacturer => manuf,
                 :origin => row['Herkomst'],
                 :unit => unit,
                 :price => unit_price,
                 :unit_quantity => unit_quantity,
                 :tax => row['BTW-%'],
                 :deposit => 0,
                 :category => row['Subgroep']}
      # not part of original BD-Totaal file
      case row['Status']
      when "x"
        # check if the article is outlisted
        outlisted_articles << article
      else
        articles << article
      end
    end
    return [articles, outlisted_articles, nil]
  end

  protected

  # remove currency symbol from price
  def self.parse_price(price)
    price.gsub(/^\s*[^0-9]+\s*/, '').to_f
  end

  # there is one field containing both unit and unit quantity
  #   "per kg",   "1x300 gr",    "1x1,5 kg",    "1x8x25 gr",    "1x10 bs"
  # returns unit, unit_quantity
  #   [1, "kg"],  [1, "300 gr"], [1, "1.5 kg"], [1, "8x25 gr"], [10, "bs"]
  # sometimes the order is unclear, so we compare the price of one unit with
  # the price of the full pack
  def self.parse_inhoud(s, unit_price, total_price)
    s.gsub! /^per\s*/, '' and return s, 1
    s.gsub! /,/, '.' # use decimal point
    parts, unit = s.split /\s+/, 2
    parts = parts.split('x')
    i = parts.index { |p| (p.to_f * unit_price - total_price) < 1e-3 }
    raise Exception, "Could not find unit quantity for 'Inhoud': #{s}" unless i
    unit_quantity = parts.delete_at(i)
    return "#{parts.join('x')} #{unit}", unit_quantity
  end
  
end
