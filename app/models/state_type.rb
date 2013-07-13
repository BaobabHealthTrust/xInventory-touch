class StateType < ActiveRecord::Base
  default_scope where("#{table_name}.voided = 0")
  # attr_accessible :title, :body
end
