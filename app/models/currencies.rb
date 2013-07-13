class Currencies < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where('voided = 0')                                             

end
