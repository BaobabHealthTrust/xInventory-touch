class Project < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where('voided = 0')

  belongs_to :donor , :class_name => :Donor, :foreign_key => :donor                                                            
  has_many :assets, :class_name => :Item , :foreign_key => :project_id
end
