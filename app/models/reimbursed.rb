class Reimbursed < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :transfer_transaction, :class_name => :TransferTransations, 
    :foreign_key => :transfer_transation_id
  belongs_to :asset, :class_name => :Item, :foreign_key => :reimbursed_item_id
end
