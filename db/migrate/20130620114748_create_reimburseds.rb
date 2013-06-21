class CreateReimburseds < ActiveRecord::Migration
  def change
    create_table :reimburseds do |t|
      t.integer :transfer_transation_id, :null => false
      t.integer :reimbursed_item_id, :null => false
      t.date :reimbursed_date, :null => false

      t.timestamps
    end
  end

  def self.down                                                                 
    drop_table :reimburseds
  end 

end
