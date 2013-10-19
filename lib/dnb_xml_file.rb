# Module for De Nieuw Band XML import
 
module DnbXmlFile
  
  # parses a string
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(data)
    articles, outlisted_articles = Array.new, Array.new
    xml = Hash.from_xml(data)
    xml['xmlproduct']['product'].each do |row|
      # create a new article
      unit = (row['eenheid'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = 'ltr' # unit currently needs to be at least 2 characters
      not row['inhoud'].nil? and row['inhoud'].to_i > 1 and unit = row['inhoud'].gsub(/\.0+\s*$/,'') + unit
      article = {:number => prod['bestelnummer'],
                 #:ean => row['eancode'],
                 :name => row['omschrijving'],
                 :note => row['kwaliteit'],
                 :manufacturer => row['merk'],
                 :origin => row['herkomst'],
                 :unit => unit,
                 :price => row['prijs']['inkoopprijs'],
                 :unit_quantity => row['sve'], 
                 :tax => row['btw'],
                 :deposit => row['statiegeld'],
                 :category => row['trefwoord']}
      # check if the article is outlisted
      case row['status']
      when "Actief"
        articles << article
      else
        outlisted_articles << article
      end
    end
    return [articles, outlisted_articles]
  end
    
  # return most probable column separator character from first line
  def self.csv_guess_col_sep(data)
    seps = [",", ";", "\t", "|"]
    firstline = data[0..(data.index("\n")||-1)]
    seps.map {|x| [firstline.count(x),x]}.sort_by {|x| -x[0]}[0][1]
  end

end
