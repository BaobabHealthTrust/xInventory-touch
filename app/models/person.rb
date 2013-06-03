class Person < ActiveRecord::Base
  default_scope where("#{table_name}.voided = 0")
  # attr_accessible :title, :body

  has_one :user, :foreign_key => :person_id 
end
