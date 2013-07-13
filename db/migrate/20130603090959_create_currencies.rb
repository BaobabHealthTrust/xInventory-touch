class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :code, :null => false, :unique => true
      t.string :abbreviation, :null => false, :unique => true
      t.string :description, :null => true
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true              

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :currencies
  end

end
