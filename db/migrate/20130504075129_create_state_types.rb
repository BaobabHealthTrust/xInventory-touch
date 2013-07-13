class CreateStateTypes < ActiveRecord::Migration
  def change
    create_table :state_types do |t|
      t.string :name, :null => false
      t.text :description, :null => true
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :state_types                                                        
  end 

end
