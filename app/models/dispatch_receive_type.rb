class DispatchReceiveType < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where("#{table_name}.voided = 0")

  has_many :transactions, :class_name => :DispatchReceive, :foreign_key => :transaction_type
end
