# == Schema Information
#
# Table name: articles
#
#  id             :integer(4)      not null, primary key
#  name           :string(255)     not null
#  supplier_id    :integer(4)      not null
#  number         :string(255)
#  note           :string(255)
#  manufacturer   :string(255)
#  origin         :string(255)
#  unit           :string(255)
#  price          :decimal(8, 2)   default(0.0), not null
#  tax            :decimal(3, 1)   default(7.0), not null
#  deposit        :decimal(8, 2)   default(0.0), not null
#  unit_quantity  :decimal(4, 1)   default(1.0), not null
#  scale_quantity :decimal(4, 2)
#  scale_price    :decimal(8, 2)
#  created_on     :datetime
#  updated_on     :datetime
#  list           :string(255)
#

require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
