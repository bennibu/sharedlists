# Module for De Nieuw Band XML import
require 'nokogiri'
 
module DnbXmlFile

  def self.name
    "De Nieuwe Band (XML)"
  end

  def self.detect(file, opts={})
    FileHelper.skip_until(file, /<\?xml/).nil? and return 0
    FileHelper.skip_until(file, /<\s*xmlproduct\s*>/).nil? and return 0
    return 0.9
  end
  
  # parses a string or file
  def self.parse(file, opts={})
    doc = Nokogiri.XML(file, nil, nil,
      Nokogiri::XML::ParseOptions::RECOVER +
      Nokogiri::XML::ParseOptions::NONET +
      Nokogiri::XML::ParseOptions::COMPACT # do not modify doc!
    )
    doc.search('product').each do |row|
      # create a new article
      unit = (row.search('eenheid').text or 'st')
      unit == 'stuk' and unit = 'st'
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = 'ltr' # unit currently needs to be at least 2 characters
      inhoud = row.search('inhoud').text
      inhoud.blank? or (inhoud.to_f-1).abs > 1e-3 and unit = inhoud.gsub(/\.0+\s*$/,'') + unit
      deposit = row.search('statiegeld').text
      deposit.blank? and deposit = 0
      article = {:number => row.search('bestelnummer').text,
                 #:ean => row.search('eancode').text,
                 :name => row.search('omschrijving').text,
                 :note => row.search('kwaliteit').text,
                 :manufacturer => row.search('merk').text,
                 :origin => row.search('herkomst').text,
                 :unit => unit,
                 :price => row.search('prijs inkoopprijs').text,
                 :unit_quantity => row.search('sve').text, 
                 :tax => row.search('btw').text,
                 :deposit => deposit,
                 :category => row.search('trefwoord').text}
      yield article, (row.search('status') == 'Actief' ? :outlisted : nil)
    end
  end

end
