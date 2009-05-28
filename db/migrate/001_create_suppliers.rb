class CreateSuppliers < ActiveRecord::Migration
  SUPPLIER_SAMPLE = 'Sample Supplier'
  
  def self.up
    create_table :suppliers do |t|
      t.column :name, :string, :null => false  
      t.column :address, :string, :null => false  
      t.column :phone, :string, :null => false  
      t.column :phone2, :string
      t.column :fax, :string
      t.column :email, :string
      t.column :url, :string
      t.column :delivery_days, :string
      t.column :note, :string
      
      t.column :created_on, :datetime
      t.column :updated_on, :datetime
    end
    add_index(:suppliers, :name, :unique => true)
    
    # Create sample supplier...
    puts "Creating sample supplier '#{SUPPLIER_SAMPLE}'..."
    Supplier.create(:name => SUPPLIER_SAMPLE, :address => "Organic City", :phone => "0123-555555")
    raise "Failed!" unless supplier = Supplier.find_by_name(SUPPLIER_SAMPLE)
    
  end

  def self.down
    drop_table :suppliers
  end
end
