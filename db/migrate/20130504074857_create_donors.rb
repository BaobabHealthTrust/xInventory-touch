class CreateDonors < ActiveRecord::Migration
  def change
    create_table :donors do |t|
      t.string :name, :null => false
      t.string :abbreviation, :null => true
      t.text :description
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :donors                                                      
  end

end
