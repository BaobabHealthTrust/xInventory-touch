class Donor < ActiveRecord::Base
  default_scope where("#{table_name}.voided = 0")

  has_many :projects, :class_name => :Project,:foreign_key => :donor_id
  has_many :assets, :class_name => :Item,:foreign_key => :donor_id

end
