class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :null => false, :unique => true
      t.text :password_hash, :null => false
      t.integer :person_id, :null => false
      t.string :email
      t.string :phone_number
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true              

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :users                                                       
  end

end
