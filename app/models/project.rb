class Project < ActiveRecord::Base
  default_scope where('voided = 0')
  # attr_accessible :title, :body
end
