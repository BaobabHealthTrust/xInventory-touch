class CreateUserRoles < ActiveRecord::Migration
  def change
    create_table :user_roles do |t|
      t.integer :user_id, :null => false
      t.string :role, :null => false
    end

    remove_column :user_roles, :id
  end

  def self.down                                                                 
    drop_table :user_roles                                                   
  end

end
