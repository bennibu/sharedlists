
module FileHelper

  # return most probable column separator character from first line
  def self.csv_guess_col_sep(data)
    seps = [",", ";", "\t", "|"]
    firstline = data[0..(data.index("\n")||-1)]
    seps.map {|x| [firstline.count(x),x]}.sort_by {|x| -x[0]}[0][1]
  end

end
