class Site < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where("#{table_name}.voided = 0")

  has_many :assets, :class_name => :Item, :foreign_key => :location
end
