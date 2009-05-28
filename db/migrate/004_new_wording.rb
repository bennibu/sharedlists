class NewWording < ActiveRecord::Migration
  def self.up
    rename_column :articles, :refund, :deposit
    # and make 0.0 deposit the default ...
    change_column :articles, :deposit, :decimal, :precision => 8, :scale => 2, :default => 0.0, :null => false
  end

  def self.down
  end
end
