# Module for De Nieuw Band import
# The FoodSoft-File is a csv-file
 
require 'csv'

module DnbCsvFile

  def self.name
    "De Nieuwe Band (CSV)"
  end

  def self.detect(data)
    # header names in first line of input
    firstline = data[0..(data.index("\n")||-1)]
    somefields = [/art\.nr\./, /omschrijving/, /kwaliteit/, /merk/, /land/, /eenheid/, /aantal/, /btw/]
    somefields.select{|re| firstline.match re}.count / somefields.count
  end
  
  # the parsed article is a simple hash
  def self.parse(data)
    CSV.parse(data, {:col_sep => FileHelper.csv_guess_col_sep(data), :headers => true}) do |row|
      # skip empty lines
      (row[2] == "" || row[2].nil?) and next
      # create a new article
      unit = (row['eenheid'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = 'ltr' # unit currently needs to be at least 2 characters
      not row['inhoud'].nil? and row['inhoud'].to_i > 1 and unit = row['inhoud'] + unit
      tax = case row['btw'].to_i
        when 0 then 0.0
        when 1 then 6.0
        when 2 then 21.0
        else '?'
      end
      article = {:number => row['art.nr.'],
                 :name => row['omschrijving'],
                 :note => row['kwaliteit'],
                 :manufacturer => row['merk'],
                 :origin => row['land'],
                 :unit => unit,
                 :price => row['inkoopprijs'],
                 :unit_quantity => row['aantal'],
                 :tax => tax,
                 :deposit => row['statiegeld'],
                 :category => row['trefwoord']}
      yield article, (row['status'] == 'x' ? :outlisted : nil)
    end
  end
    
end
