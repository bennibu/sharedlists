# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120312184452) do

  create_table "articles", :force => true do |t|
    t.string   "name",                                                          :null => false
    t.integer  "supplier_id",                                                   :null => false
    t.string   "number"
    t.string   "note"
    t.string   "manufacturer"
    t.string   "origin"
    t.string   "unit"
    t.decimal  "price",          :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "tax",            :precision => 3, :scale => 1, :default => 7.0, :null => false
    t.decimal  "deposit",        :precision => 8, :scale => 2, :default => 0.0, :null => false
    t.decimal  "unit_quantity",  :precision => 4, :scale => 1, :default => 1.0, :null => false
    t.decimal  "scale_quantity", :precision => 4, :scale => 2
    t.decimal  "scale_price",    :precision => 8, :scale => 2
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "list"
  end

  add_index "articles", ["name"], :name => "index_articles_on_name"
  add_index "articles", ["number", "supplier_id"], :name => "index_articles_on_number_and_supplier_id", :unique => true

  create_table "suppliers", :force => true do |t|
    t.string   "name",                             :null => false
    t.string   "address",                          :null => false
    t.string   "phone",                            :null => false
    t.string   "phone2"
    t.string   "fax"
    t.string   "email"
    t.string   "url"
    t.string   "delivery_days"
    t.string   "note"
    t.datetime "created_on"
    t.datetime "updated_on"
    t.string   "lists"
    t.boolean  "bnn_sync",      :default => false
    t.string   "bnn_host"
    t.string   "bnn_user"
    t.string   "bnn_password"
  end

  add_index "suppliers", ["name"], :name => "index_suppliers_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email"
    t.string   "password_hash"
    t.string   "password_salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
