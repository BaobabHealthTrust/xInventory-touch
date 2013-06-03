class Item < ActiveRecord::Base
  # attr_accessible :title, :body
  default_scope where('voided = 0')

  belongs_to :category , :class_name => :Category, :foreign_key => :category_type                                                            
  belongs_to :donor , :class_name => :Donor, :foreign_key => :donor_id                                                           
  belongs_to :project , :class_name => :Project, :foreign_key => :project_id
  belongs_to :supplier , :class_name => :Supplier, :foreign_key => :vendor
  belongs_to :manufacturer , :class_name => :Manufacturer, :foreign_key => :brand
  belongs_to :site , :class_name => :Site, :foreign_key => :location
  belongs_to :current_state, :class_name => :ItemState,:foreign_key => :item_id
  belongs_to :currency, :class_name => :Currencies, :foreign_key => :currency
end
