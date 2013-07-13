class CreateDispatchReceiveTypes < ActiveRecord::Migration
  def change
    create_table :dispatch_receive_types do |t|
      t.string :name, :null => false
      t.text :description
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :dispatch_receive_types
  end 

end
