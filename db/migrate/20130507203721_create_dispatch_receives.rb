class CreateDispatchReceives < ActiveRecord::Migration
  def change
    create_table :dispatch_receives do |t|

      t.timestamps
    end
  end
end
