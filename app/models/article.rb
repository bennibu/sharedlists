class Article < ActiveRecord::Base
  belongs_to :supplier
  
  validates_numericality_of :price, :tax, :deposit, :unit_quantity
  validates_uniqueness_of :number, :scope => :supplier_id
  validates_presence_of :name, :price
  
  
  # Custom attribute setter that accepts decimal numbers using localized decimal separator.
  def price=(price)
    self[:price] = delocalizeDecimalString(price)
  end
  def unit_quantity=(unit_quantity)
    self[:unit_quantity] = delocalizeDecimalString(unit_quantity)
  end
  def tax=(tax)
    self[:tax] = delocalizeDecimalString(tax)
  end
  def deposit=(deposit)
    self[:deposit] = delocalizeDecimalString(deposit)
  end
  def scale_quantity=(scale_quantity)
    self[:scale_quantity] = delocalizeDecimalString(scale_quantity)
  end
  def scale_price=(scale_price)
    self[:scale_price] = delocalizeDecimalString(scale_price)
  end
  
  def delocalizeDecimalString(string)
    if (string && string.is_a?(String) && !string.empty?)
      separator = ","
      if (separator != '.' && string.index(separator))
        string = string.sub(separator, '.')
      end      
    end
    return string
  end
end
