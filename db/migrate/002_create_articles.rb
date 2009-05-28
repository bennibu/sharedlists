class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.column :name, :string, :null => false
      t.column :supplier_id, :integer, :null => false
      t.column :number, :string
      t.column :note, :string
      t.column :manufacturer , :string
      t.column :origin, :string
      t.column :unit, :string
      
      # now the price and order conditions
      t.column :price, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0.00
      t.column :tax, :decimal, :precision => 3, :scale => 1,:null => false, :default => 7.0
      t.column :refund, :decimal, :precision => 8, :scale => 2, :null => false, :default => 0.00
      t.column :unit_quantity, :decimal, :precision => 4, :scale => 1,:null => false, :default => 1
      
      # the price-quantity-scale
      t.column :scale_quantity, :decimal, :precision => 4, :scale => 2
      t.column :scale_price, :decimal, :precision => 8, :scale => 2
      
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
      
    end
    add_index(:articles, :name)
    add_index(:articles, [:number, :supplier_id], :unique => true)
  end

  def self.down
    drop_table :articles
  end
end
