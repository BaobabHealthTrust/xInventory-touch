class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name, :null => false
      t.integer :donor_id, :null => false
      t.text :description
      t.boolean :voided, :null => false, :default => false                      
      t.text :void_reason, :null => true

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :projects                                                          
  end

end
