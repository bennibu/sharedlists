# Module for De Nieuw Band import
# The FoodSoft-File is a csv-file
 
require 'csv'

module DNBFile
  
  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(data)
    articles, outlisted_articles = Array.new, Array.new
    CSV.parse(data, {:col_sep => csv_guess_col_sep(data), :headers => true}) do |row|
      # skip empty lines
      (row[2] == "" || row[2].nil?) and next
      # create a new article
      unit = (row['eenheid'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      unit == 'l' and unit = '1L' # unit currently needs to be at least 2 characters
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
      case row['status']
      when "x"
        # check if the article is outlisted
        outlisted_articles << article
      else
        articles << article
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
