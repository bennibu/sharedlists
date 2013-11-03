# Module for BD-Totaal CSV import
 
require 'csv'

module BdtotaalFile

  def self.name
    "BD-Totaal (CSV)"
  end

  def self.detect(file, opts={})
    # when there is a line starting with BD-Totaal
    file.read(200).match(/(^|\n)\s*BD-Totaal/m) ? 0.9 : 0
  end
  
  # the parsed article is a simple hash
  def self.parse(file, opts={})
    # first few lines may be contact info
    col_sep = FileHelper.csv_guess_col_sep(file)
    FileHelper.skip_until file, /^\s*Artikelcode/
    headclean = Proc.new {|x| x.gsub(/^\s*(.*?)\s*$/, '\1') unless x.nil?} # remove whitespace around headers
    CSV.new(file, {:col_sep => col_sep, :headers => true}).each do |row|
      # skip empty lines
      row[0].blank? and next

      # create a new article
      error = nil
      name = row['Artikelomschrijving']
      manuf = row['Merknaam']
      notes = [row['Kwaliteit']]
      unit_price = parse_price(row['Eenheidsprijs'])
      pack_price = parse_price(row['Colloprijs'])
      begin
        unit_quantity, unit, unit_price = parse_inhoud(row['Inhoud'], unit_price, pack_price, row['Subgroep'])
      rescue Exception => e
        # in case of a problem, we can always just order the full pack
        unit, unit_quantity, unit_price = row['Inhoud'], 1, pack_price
        error = e.message
      end
      manuf, name = parse_manuf(manuf, name, unit, row['Hoofdgroep'])
      article = {:number => row['Artikelcode'],
                 :name => name,
                 :note => notes.join("\n"),
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
    price.gsub(/^\s*[^0-9]+\s*/, '').to_f unless price.nil?
  end

  # some manufacturer names actually contain extra product info
  def self.parse_manuf(manuf, name, unit, maincategory)
    unless manuf.blank?
      [
        /\bper\s+(.*)\b/i,
        /\b(verpakt|los|hand|rond|emmer|geperforeerd|afbreekbaar)\b/i,
        /\b(in dop|moes|grof|gebroken|blad|met loof|stoof|pers|kook(appel)|verwerkt?)\b/i,
        /\b(paars)\b/i,
        /\b((x?\s*[0-9.,]+\s*){2,})$/i,
        /\b(((x?\s*[0-9.,]+\s*)+(m|mm|cm|gr|kg))\s*(x?\s*[0-9.,]+\s*)?)$/i,
      ].each do |re|
        if m=manuf.match(re)
          m = m[1].downcase.gsub(/^\s*(.*?)\s*$/, '\1')
          name += " (#{m})" unless m == unit or m == 'stuk'
          manuf.gsub! re, ''
        end
      end
      if "#{maincategory}".match(/textiel/i) and !name.match(/koksjas/i)
        m = manuf.downcase.gsub(/^\s*(.*?)\s*$/, '\1')
        name += " (#{m})"
        manuf = ''
      end
      manuf.gsub! /\s+/, ' '
      manuf.match(/^\s+$/) and manuf = nil
    end
    return manuf, name, maincategory
  end

  # there is one field containing both unit and unit quantity
  #   "per kg",   "1x300 gr",    "1x1,5 kg",    "1x8x25 gr",    "1x10 bs"
  # returns unit, unit_quantity, unit_price
  #   [1, "kg",],  [1, "300 gr",], [1, "1.5 kg",], [1, "8x25 gr",], [10, "bs",]
  # sometimes the order is unclear, so we compare the price of one unit with
  # the price of the full pack
  def self.parse_inhoud(s, unit_price, pack_price, category)
    s.nil? and return 1, nil, unit_price

    s.gsub! /^\s+/, ''; s.gsub! /\s+$/, ''
    s.gsub! /,/, '.' # use decimal point
    s.gsub! /^per\s*/i, '' and return 1, s, unit_price

    # catch clothing and textile putting size in unit field
    if category.match(/(kleding|textiel)/i) and
       (s.match(/^([0-9\/]+)?\s*\(?[smlx\/]*\)?$/i) or s.match(/cm$/))
      unit_quantity = pack_price / unit_price
      (unit_quantity - unit_quantity.floor).abs >= 1e-3 and
        raise Exception, "price-based unit quantity #{pack_price}/#{unit_price}=#{unit_quantity.round(2)} is not a whole number (textile, '#{s}')"
      return unit_quantity.to_i, s, unit_price
    end

    preunit = s.gsub!(/ong[^0-9]+/i, '') ? 'ca. ' : ''
    parts, unit = s.split /\s+/, 2
    # fix units
    "#{unit}".match(/^st/) and unit = 'st'
    "#{unit}".match(/^plak/) and unit = 'plak'
    unit == 'lt' and unit = 'ltr'
    unit == 'bs' and unit = 'bos'
    unit == 'mtr' and unit = 'm'

    # if prices are equal it's easy
    (unit_price - pack_price).abs < 1e-3 and
      return 1, "#{preunit}#{parts.gsub(/^\s*1x/,'')} #{unit}", unit_price

    parts = parts.split(/x/i)

    # perhaps the unit_price is the kg or litre price
    mul, mulunit = parts.map(&:to_f).reduce {|x,y| x*y}, unit
    mulunit == 'gr' and mulunit = 'kg' and mul = mul/1000
    mulunit == 'ml' and mulunit = 'ltr' and mul = mul/1000
    if (mul*unit_price - pack_price).abs < 1e-2
      unit_quantity = parts.delete_at(0)
      return unit_quantity, "#{preunit}#{parts.join('x')} #{unit}", pack_price/unit_quantity.to_f
    end

    # for some articles unit_price is price/kg and haven't been catched
    category.match /(per\s+|\/)kg/i and return 1, preunit+parts.join('x').gsub(/^1x/,''), pack_price

    # consistency check (2nd check is for "6x5x64 ml" ice, where unit_price is per subbox of 64ml)
    pack_price_computed = parts[0].to_f * unit_price
    (pack_price_computed - pack_price).abs < 1e-2 or ((parts.size>1 and pack_price_computed*parts[1].to_f - pack_price).abs < 1e-2) or
      raise Exception, "price per pack given #{pack_price} does not match computed #{parts[0]}*#{unit_price}=#{pack_price_computed.round(2)} in '#{s}'"

    return parts.delete_at(0), "#{preunit}#{parts.join('x')} #{unit}", unit_price
  end
  
end
