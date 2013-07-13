class UserRole < ActiveRecord::Base
  # attr_accessible :title, :body
  belongs_to :user, :foreign_key => :user_id, :conditions => {:voided => 0}
end
