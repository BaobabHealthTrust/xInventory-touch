class Site < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where("#{table_name}.voided = 0")

  has_many :assets, :class_name => :Item, :foreign_key => :location

  def self.current_location_id
  	Thread.current[:id]
  end


  def self.current_location_id=(id)
    Thread.current[:id] = id
  end

	def self.current_location
		self.find(self.current_location_id)
	end
end
