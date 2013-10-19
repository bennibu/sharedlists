# Module for import of TerraSana products from their Excel sheet
# Please export the excel sheet as CSV, and import that.
 
require 'csv'

module TerrasanaFile
  
  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(data)
    articles, outlisted_articles = Array.new, Array.new
    category = nil
    category_note = nil
    CSV.parse(data, {:col_sep => FileHelper.csv_guess_col_sep(data), :headers => true}) do |row|
      # skip empty lines
      (row[0] == "" || row[0].nil?) and next
      # categories take their own line
      if (row[4].nil? or row[4].blank?) and (row[5].nil? or row[5].blank?)
        category = row[3].gsub(/(\s)\s*/, '\1')
        category_note = []
        # "nieuw" after category name
        m = category.match(/^(.*?)\s*("?NIEUW.*)?\s*$/i) and category = m[1] #and category_note << m[2]
        # lowercase note after category name
        m = category.match(/^([^a-z]+?)\s+([a-z].*?)?\s*$/) and category = m[1] and category_note << m[2]
        category_note = category_note ? category_note.join("\n") : nil
        next
      end
      Rails.logger.info [row[3],row[4],row[5]]
      # create a new article
      unit = (row['E'] or 'st')
      unit == 'g' and unit = 'gr' # unit currently needs to be at least 2 characters
      not row['P'].nil? and row['P'].to_i > 1 and unit = row['P'] + unit
      article = {:number => row['ArtCode'],
                 #:ean => row['EAN'],
                 :name => row['Omschrijving Nederlands'],
                 :note => [ row['Kwal'], category_note ].compact.join("\n"),
                 :manufacturer => row['Merk'],
                 #:origin => nil,
                 :unit => unit,
                 :price => row['Detail'],
                 :unit_quantity => row['V'],
                 :tax => row['Btw'],
                 :deposit => 0,
                 :category => category}
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
    
end
