class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name, :null => false    
      t.integer :category_type, :null => false                          
      t.text :description, :null => true
      t.string :brand, :null => false
      t.string :version, :null => false
      t.string :model, :null => false
      t.string :serial_number, :unique => true, :null => false
      t.integer :vendor, :null => false
      t.integer :project_id, :null => false
      t.integer :donor_id, :null => false
      t.date :purchased_date, :null => false
      t.string :order_number, :null => false
      t.float :current_quantity, :null => false
      t.float :bought_quantity, :null => false
      t.float :cost, :null => false
      t.date :date_of_receipt, :null => false
      t.string :delivered_by, :null => false
      t.integer :status_on_delivery, :null => false
      t.integer :location, :null => false
      t.boolean :voided, :null => false, :default => false
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :items                                                       
  end

end
