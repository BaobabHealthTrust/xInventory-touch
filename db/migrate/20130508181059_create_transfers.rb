class CreateTransfers < ActiveRecord::Migration
  def change
    create_table :transfers do |t|
      t.date :transfer_date, :null => false                                    
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :items                                                           
  end

end
