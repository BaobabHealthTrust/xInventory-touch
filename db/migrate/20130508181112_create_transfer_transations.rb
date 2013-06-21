class CreateTransferTransations < ActiveRecord::Migration
  def change
    create_table :transfer_transations do |t|
      t.integer :transfer_id, :null => false                                            
      t.integer :asset_id, :null => false
      t.integer :from_project, :null => false                                   
      t.integer :from_donor, :null => false                                     
      t.integer :from_location, :null => false                                  
      t.integer :to_project, :null => false                                     
      t.integer :to_donor, :null => false                                       
      t.boolean :returned, :null => false, :default => false
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

                                                                                
  def self.down                                                                 
    drop_table :transfer_transations                                                           
  end 

end
