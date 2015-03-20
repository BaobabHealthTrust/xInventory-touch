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

  def barcode_label
    label = ZebraPrinter::StandardLabel.new
    label.font_size = 2
    label.font_horizontal_multiplier = 2
    label.font_vertical_multiplier = 2
    label.left_margin = 50
    label.draw_barcode(50,180,0,1,5,15,120,false,"#{self.id}")
    label.draw_multi_text("#{self.name.titleize}")
    label.print(1)
  end
end
