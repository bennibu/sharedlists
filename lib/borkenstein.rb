# -*- coding: utf-8 -*-
# Module for Borkenstein csv import
 
require 'csv'

module Borkenstein

  REGEX = {
    :main => /^(.+)\s+\[([^\[\]]+)\]\s+(\d+\.\d+)\((\d+\.\d+)\)$/,
    :manufacturer => /^(.+)\s{4}\[\]\s{4}\(\)$/,
    :origin => /(.+)\s+(\w+)\/\w+[\/[\w\-]+]?/
  }

  def self.name
    "Borkenstein (CSV)"
  end

  def self.detect(data)
     0 # TODO
  end
  
  # parses a string from a foodsoft-file
  # the parsed article is a simple hash
  def self.parse(data)
    global_manufacturer = nil

    CSV.parse(data, {:col_sep => ",", :headers => false}) do |row|

      # Set manufacturer
      if row[1] == "-"
        match = row[2].match(REGEX[:manufacturer])
        global_manufacturer = match.captures.first unless match.nil?
      end

      # check if the line is empty
      unless row[1].blank? || row[1] == "-"

        # Split string and remove beginning "
        matched = row[2].gsub(/^\"/, "").gsub(/\"$/, "").match(REGEX[:main])

        if matched.nil?
          puts "No regular article data for #{row[1]}: #{row[2]}"
          
        else

          name, units, price_high, price_low = matched.captures

          # Try to get origin
          matched_name = name.match(REGEX[:origin])
          if matched_name
            name, origin = matched_name.captures
          else
            name, origin = name.gsub(/\s{2,}/, ""), nil
          end

          # Manufacturer
          if name.match(/^[A-Za-z]{2,3}\s{1}/)
            name.gsub!(/^[A-Za-z]{2,3}\s{1}/, "")
            manufacturer = global_manufacturer
          end


          # Get unit quantities
          units = units.split("x")
          if units.size == 2
            unit_quantity = units.first
            unit = units.last
          else
            unit_quantity = 1
            unit = units.first
          end

          article = {
            :number => row[1],
            :name => name,
            :origin => origin,
            :manufacturer => manufacturer,
            :unit_quantity => unit_quantity,
            :unit => unit,
            :price => price_low, # Inklusive Rabattstufe von 10%
            :tax => 0.0 # Tax is included
          }

          # test, if neccecary attributes exists
          if article[:unit].nil? || article[:price].nil? || article[:unit_quantity].nil?
            raise "Fehler: Einheit, Preis und MwSt. müssen gegeben sein: #{article.inspect}"
          end

          yield article, nil
        end
      end
    end
  end
    
end
