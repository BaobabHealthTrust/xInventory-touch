class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :first_name, :null => false
      t.string :last_name, :null => false
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :people                                                           
  end

end
