class DispatchReceive < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where('voided = 0')

  belongs_to :transaction_type , 
    :class_name => :DispatchReceiveType, :foreign_key => :transaction_type                                                            

end
