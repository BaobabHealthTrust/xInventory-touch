class CreateItemStates < ActiveRecord::Migration
  def change
    create_table :item_states do |t|
      t.integer :current_state, :null => false
      t.integer :item_id, :null => false

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :item_states                                                           
  end

end
