class HomeController < ApplicationController
  def index
    @total_registered_assets = Item.count
    @total_available_assets = 0 
    @total_missing_assets = 0

=begin
    @start_date = Item.order("MIN(purchased_date)").first.try(:purchased_date).to_date rescue Date.today        
    @items = [] ; items = {:bought => 0 , :current => 0} ; count = 1        
    assets = Item.order(:category_type)
                            
    (assets || []).each do |asset|                                         
      if items[asset.name].blank?
        items[asset.purchased_date.to_date] = [
          "#{asset.name}" => {:bought => 0 , :current => 0}
        ]
      end
      items[asset.purchased_date] = [
        "#{asset.name}" => {
          :bought => items[asset.purchased_date.to_date][0]["#{asset.name}"][:bought] + asset.bought_quantity,
          :current => items[asset.purchased_date.to_date][0]["#{asset.name}"][:current] + asset.current_quantity 
        }
      ]
    end

    (items || {}).sort { |k| k.keys } .each do |date,values|
      @items << [date.to_date.strftime('%d.%b.%y') , ]                  
    end                                                                         
                                                                                
    @weights = @weights.to_json
=end
  
  end

  def summary 
    render :layout => false
  end

  def get_summary   
    @items = {}
    names = [
      'J2 Touchsreen','Laptop','Ribbons','Usb Scanner',
      'Step Down Transformer',"Router","Mobile Phone",
      "Lcd Monitor","Cisco Network Switch","Batteries"
    ]

    start_date = (Date.today - 12.month)
    end_date = Date.today

    assets = Item.order(:purchased_date).where("name IN(?)",names)

    (assets || []).each do |asset|
      if @items[asset.name].blank?        
        @items[asset.name] = [0,0,0,0,0,0,0,0,0,0,0,0]
      end
      @items[asset.name][((asset.purchased_date.month) - 1)] = @items[asset.name][((asset.purchased_date.month) - 1)] + asset.current_quantity 
    end                                                                         
    
    render :text => @items = @items.to_json and return
  end


end
