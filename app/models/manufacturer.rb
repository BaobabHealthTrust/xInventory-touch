class Manufacturer < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where('voided = 0')

  has_many :assets, :class_name => :Item,:foreign_key => :brand
end
