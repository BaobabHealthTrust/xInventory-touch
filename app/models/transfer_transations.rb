class TransferTransations < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :transfer, :class_name => :Transfer, :foreign_key => :id
  has_one :reimbursed_record, :class_name => :Reimbursed, :foreign_key => :transfer_transation_id

end
