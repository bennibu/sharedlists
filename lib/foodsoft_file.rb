# Module for FoodSoft-File import
# The FoodSoft-File is a cvs-file, with semicolon-seperatet columns
 
require 'csv'

module FoodsoftFile
  
  # parses a string from a foodsoft-file
  # returns two arrays with articles and outlisted_articles
  # the parsed article is a simple hash
  def self.parse(data)
    articles, outlisted_articles = Array.new, Array.new
    CSV.parse(data, {:col_sep => ";", :headers => true}) do |row|
      # check if the line is empty
      unless row[2] == "" || row[2].nil?
        # test, if neccecary attributes exists
        raise "Fehler: Einheit, Preis und MwSt. müssen gegeben sein" if row[6].nil? || row[7].nil? || row[8].nil?
        
        article = {:number => row[1],
                   :name => row[2],
                   :note => row[3],
                   :manufacturer => row[4],
                   :origin => row[5],
                   :unit => row[6],
                   :price => row[7],
                   :tax => row[8],
                   :unit_quantity => row[10],
                   :scale_quantity => row[11],
                   :scale_price => row[12],
                   :category => row[13]}
        article.merge!(:deposit => row[9]) unless row[9].nil?
        case row[0]
        when "x"
          # check if the article is outlisted
          outlisted_articles << article
        else
          articles << article
        end
      end
    end
    return [articles, outlisted_articles]
  end
    
end
