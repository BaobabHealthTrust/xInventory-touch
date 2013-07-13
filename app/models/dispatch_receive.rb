class DispatchReceive < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where("#{table_name}.voided = 0")

  belongs_to :type_of_transaction , 
    :class_name => :DispatchReceiveType, :foreign_key => :transaction_type                                                            

end
