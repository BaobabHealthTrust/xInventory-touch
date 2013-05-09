class Category < ActiveRecord::Base
  default_scope where('voided = 0')
  # attr_accessible :title, :body

  has_many :assets, :class_name => :Item , :foreign_key => :category_type
end
