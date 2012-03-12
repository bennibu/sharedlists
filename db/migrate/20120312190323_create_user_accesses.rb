class CreateUserAccesses < ActiveRecord::Migration
  def self.up
    create_table :user_accesses do |t|
      t.integer :user_id
      t.integer :supplier_id

      t.timestamps
    end

    add_index :user_accesses, :user_id
    add_index :user_accesses, :supplier_id
    add_index :user_accesses, [:user_id, :supplier_id]
  end

  def self.down
    drop_table :user_accesses
  end
end
