class AddBnnSyncToSuppliers < ActiveRecord::Migration
  def self.up
    add_column :suppliers, :bnn_sync, :boolean, :default => false
    add_column :suppliers, :bnn_host, :string
    add_column :suppliers, :bnn_user, :string
    add_column :suppliers, :bnn_password, :string
  end

  def self.down
    remove_column :suppliers, :bnn_password
    remove_column :suppliers, :bnn_user
    remove_column :suppliers, :bnn_host
    remove_column :suppliers, :bnn_sync
  end
end
