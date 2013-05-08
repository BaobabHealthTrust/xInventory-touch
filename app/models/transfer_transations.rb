class TransferTransations < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :transfer,                                                    
        :class_name => 'Transfer', :foreign_key => 'id'

end
