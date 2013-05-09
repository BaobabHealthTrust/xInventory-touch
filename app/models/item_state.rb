class ItemState < ActiveRecord::Base
  # attr_accessible :title, :body

   belongs_to :state_type , :class_name => StateType, :foreign_key => :current_state

end
