# Module for BD-Totaal CSV import
 
require 'csv'

module BdtotaalFile

  def self.name
    "BD-Totaal (CSV)"
  end

  def self.detect(data)
    # when there is a line starting with BD-Totaal
    data[0..200].match(/(^|\n)\s*BD-Totaal/m) ? 0.9 : 0
  end
  
  # the parsed article is a simple hash
  def self.parse(data)
    data.gsub! /^.*?\n\s*(Artikelcode)/m, '\1' # first couple of lines may be a header
    headclean = Proc.new {|x| x.gsub /^\s*(.*?)\s*$/, '\1'} # remove whitespace around headers
    CSV.parse(data, {:col_sep => FileHelper.csv_guess_col_sep(data), :headers => true, :header_converters => headclean}) do |row|
      # skip empty lines
      row[0].blank? and next

      # create a new article
      error = nil
      name = row['Artikelomschrijving']
      manuf = row['Merknaam']
      # some manufacturer names are actually extra product info
      if not manuf.blank? and manuf.match /(verpakt|los)/
        name += " (#{manuf})"
        manuf = nil
      end
      unit_price = parse_price(row['Eenheidsprijs'])
      pack_price = parse_price(row['Colloprijs'])
      begin
        unit_quantity, unit, unit_price = parse_inhoud(row['Inhoud'], unit_price, pack_price, row['Subgroep'])
      rescue Exception => e
	unit, unit_quantity, unit_price = row['Inhoud'], 1, pack_price
        error = e.message
      end
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
      yield article, (error or (row['Status'] == 'x' ? :outlisted : nil))
    end
  end

  protected

  # remove currency symbol from price
  def self.parse_price(price)
    price.gsub(/^\s*[^0-9]+\s*/, '').to_f
  end

  # there is one field containing both unit and unit quantity
  #   "per kg",   "1x300 gr",    "1x1,5 kg",    "1x8x25 gr",    "1x10 bs"
  # returns unit, unit_quantity, unit_price
  #   [1, "kg",],  [1, "300 gr",], [1, "1.5 kg",], [1, "8x25 gr",], [10, "bs",]
  # sometimes the order is unclear, so we compare the price of one unit with
  # the price of the full pack
  def self.parse_inhoud(s, unit_price, pack_price, category)
    s.gsub! /^\s+/, ''; s.gsub! /\s+$/, ''
    s.gsub! /,/, '.' # use decimal point
    s.gsub! /^per\s*/, '' and return 1, s, unit_price

    # if prices are equal it's easy
    (unit_price - pack_price).abs < 1e-3 and return 1, s.gsub(/^1x/,''), unit_price

    # catch clothing and textile putting size in unit field
    if category.match(/(kleding|textiel)/i) and
       (s.match(/^([0-9\/]+)?\s*\(?[smlx\/]*\)?$/i) or s.match(/cm$/))
      unit_quantity = pack_price / unit_price
      (unit_quantity - unit_quantity.floor) >= 1e-3 and raise Exception "Textile has non-integer unit quantity #{unit_quantity}."
      return unit_quantity, s, unit_price
    end

    preunit = s.gsub!(/ong[^0-9]+/i, '') ? 'ca. ' : ''
    parts, unit = s.split /\s+/, 2
    parts = parts.split('x')
    # fix units
    "#{unit}".match(/^st/) and unit = 'st'
    "#{unit}".match(/^plak/) and unit = 'plak'
    unit == 'lt' and unit = 'ltr'

    # perhaps the unit_price is the kg or litre price
    mul = parts.map(&:to_f).reduce {|x,y| x*y}
    unit == 'gr' and unit = 'kg' and mul = mul/1000
    unit == 'ml' and unit = 'ltr' and mul = mul/1000
    (mul*unit_price - pack_price).abs < 1e-2 and
      return parts.delete_at(0), "#{preunit}#{parts.join('x')} #{unit}", pack_price

    # for some articles unit_price is price/kg and haven't been catched
    category.match /(per\s+|\/)kg/i and return 1, preunit+parts.join('x').gsub(/^1x/,''), pack_price

    # consistency check
    (parts[0].to_f*unit_price - pack_price).abs < 1e-2 or
      raise Exception, "Could not find unit quantity for 'Inhoud': #{s} (single #{unit_price}, pack #{pack_price})"

    return parts.delete_at(0), "#{preunit}#{parts.join('x')} #{unit}", unit_price
  end
  
end
