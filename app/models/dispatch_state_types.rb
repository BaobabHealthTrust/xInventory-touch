class DispatchStateTypes < ActiveRecord::Base
  
  self.default_scope -> { where "voided = 0"  }
  # attr_accessible :title, :body
end
