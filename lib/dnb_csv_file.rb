# Module for De Nieuw Band import
# The FoodSoft-File is a csv-file
 
require 'csv'

module DnbCsvFile

  def self.name
    "De Nieuwe Band (CSV)"
  end

  def self.detect(file, opts={})
    # header names in first line of input
    firstline = file.readline
    somefields = [/art\.nr\./, /omschrijving/, /kwaliteit/, /merk/, /land/, /eenheid/, /aantal/, /btw/]
    somefields.select{|re| firstline.match re}.count / somefields.count
  end
  
  def self.parse(file, opts={})
    CSV.new(file, {:col_sep => FileHelper.csv_guess_col_sep(file), :headers => true}).each do |row|
      # skip empty lines
      (row[2] == "" || row[2].nil?) and next
      # create a new article
      errors = []
      unit = (row['eenheid'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = 'ltr' # unit currently needs to be at least 2 characters
      not row['inhoud'].nil? and (row['inhoud'].to_f-1).abs > 1e-3 and unit = row['inhoud'] + unit
      tax = case row['btw'].to_i
        when 0 then 0
        when 1 then 6
        when 2 then 21
        else errors << "BTW must be 0, 1 or 2: #{row['btw']}"; '?'
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
      if errors.count > 0
        yield article, errors.join("\n")
      else
        yield article, (row['status'] == 'x' ? :outlisted : nil)
      end
    end
  end
    
end
