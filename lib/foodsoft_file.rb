# -*- coding: utf-8 -*-
# Module for FoodSoft-File import
# The FoodSoft-File is a cvs-file, with semicolon-seperatet columns
 
require 'csv'

module FoodsoftFile

  def self.name
    "Foodsoft (CSV)"
  end

  def self.detect(file, opts={})
    0 # TODO
  end
  
  # parses a string from a foodsoft-file
  # the parsed article is a simple hash
  def self.parse(file, opts={})
    CSV.new(file, {:col_sep => ";", :headers => true}).each do |row|
      # skip empty lines
      next if row[2].blank?
        
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
                 :scale_price => row[12]}
      article.merge!(:deposit => row[9]) unless row[9].nil?
      if row[6].nil? || row[7].nil? or row[8].nil?
        yield article, "Fehler: Einheit, Preis und MwSt. müssen gegeben sein"
      else
        yield article, (row[0]=='x' ? :outlisted : nil)
      end
    end
  end
    
end
