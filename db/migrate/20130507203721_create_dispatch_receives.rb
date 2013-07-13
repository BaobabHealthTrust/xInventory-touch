class CreateDispatchReceives < ActiveRecord::Migration
  def change
    create_table :dispatch_receives do |t|
      t.integer :asset_id, :null => false                                            
      t.integer :transaction_type, :null => false                                            
      t.date :encounter_date, :null => false                                   
      t.string :approved_by, :null => false                                           
      t.string :responsible_person, :null => false                                           
      t.integer :location_id, :null => false                                            
      t.float :quantity, :null => false                                            
      t.text :reason, :null => true                                        
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end
                                                                                
  def self.down                                                                 
    drop_table :dispatch_receives                                                         
  end                                                                           
     
end
