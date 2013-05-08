class Transfer < ActiveRecord::Base
  # attr_accessible :title, :body
  has_many :transfer_transactions,:class_name => 'TransferTransations',             
    :foreign_key => 'transfer_id'

end
