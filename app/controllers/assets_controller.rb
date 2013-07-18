class AssetsController < ApplicationController
  before_filter :check_authorized

  def index
    render :layout => 'index'
  end

  def find_by_barcode
    render :text => params[:barcode].to_s and return
  end

  def show
    @asset = get_asset(params[:id])

    @status = StateType.order('name ASC').collect do |state|                    
      [state.name , state.id]                                                   
    end 

    render :layout => 'menu'
  end

  def search_results
    @assets = []
    (Item.where("id IN(?)",params[:id].split(','))|| []).each do |item|
      @assets << get_asset(item.id)
    end
    render :layout => 'index'
  end

  def search
    if request.post?
      asset_ids = Item.where("serial_number 
        LIKE (?)","%#{params[:identifier]}%").map(&:id)

      if asset_ids.length == 1
        redirect_to :action => :show, :id => asset_ids.first
        return
      elsif asset_ids.length > 1
        redirect_to :action => :search_results, :id => asset_ids[0..99].join(',')
        return
      else
        @notfound  = true
      end
    end
  end

  def new
    @categories = Category.order('name ASC').collect do |category|
      [category.name , category.id]
    end

    @manufacturers = Manufacturer.order('name ASC').collect do |manu|
      [manu.name , manu.id]
    end

    @projects = Project.order('name ASC').collect do |project|
      [project.name , project.id]
    end

    @donors = Donor.order('name ASC').collect do |donor|
      [donor.name , donor.id]
    end

    @status = StateType.order('name ASC').collect do |state|
      [state.name , state.id]
    end

    @suppliers = Supplier.order('name ASC').collect do |supplier|
      [supplier.name , supplier.id]
    end

    @location = Site.order('name ASC').collect do |site|
      [site.name , site.id]
    end

    @currencies = Currencies.order('code ASC').collect do |currency|
      [currency.code , currency.id]
    end

  end

  def create
    Item.transaction do
      item = Item.new()
      item.name = params[:asset]['name']
      item.category_type = params[:asset]['category']
      item.brand = params[:asset]['manufacturer']
      item.version = params[:asset]['version']
      item.serial_number = params[:asset]['serial_num']
      item.vendor = params[:vendor]['supplier']
      item.model = params[:asset]['model']
      item.project_id = params[:work]['project']
      item.donor_id = params[:work]['donor']
      item.purchased_date = params[:vendor]['date_of_invoice'].to_date
      item.order_number = params[:vendor]['invoice_num']
      item.current_quantity = params[:vendor]['quantity']
      item.bought_quantity = params[:vendor]['quantity']
      item.cost = params[:vendor]['cost']
      item.currency_id = params[:vendor]['currency'].to_i
      item.date_of_receipt = params[:organisation]['receipt_date'].to_date
      item.delivered_by = params[:organisation]['delivered_by']
      item.status_on_delivery = params[:organisation]['delivery_status']
      item.location = params[:organisation]['location']

      asset_lifespan = (params[:asset]['lifespan']).to_i rescue 0
      if asset_lifespan > 0
        item.expiry_date = (Date.today + asset_lifespan.year)
      end

      if item.save
        curr_state = ItemState.new()                                  
        curr_state.item_id = item.id
        curr_state.current_state = StateType.find(params[:organisation]['current_status']).id            
        curr_state.save 
        flash[:notice] = 'Successfully created.'                                  
      else                                                                        
        flash[:error] = 'Something went wrong - did not create.'                  
      end
    end
    redirect_to '/create_new_asset'
  end

  def new_category
  end

  def create_category
    category = Category.new()                                                         
    category.name = params[:category]['name']                                         
    category.abbreviation = params[:category]['abv'] unless params[:category]['abv'].blank?
    category.description = params[:category]['description'] unless params[:category]['description'].blank?
    if category.save                                                               
      flash[:notice] = 'Successfully created.'                                  
    else                                                                        
      flash[:error] = 'Something went wrong - did not create.'                  
    end                                                                         
    redirect_to '/create_new_category'
  end

  def new_state
  end

  def create_state
    state = StateType.new()                                                         
    state.name = params[:state]['name']                                         
    state.description = params[:state]['description'] unless params[:state]['description'].blank?
    if state.save                                                               
      flash[:notice] = 'Successfully created.'                                  
    else                                                                        
      flash[:error] = 'Something went wrong - did not create.'                  
    end                                                                         
    redirect_to '/create_new_state'
  end

  def edit
    @asset = get_asset(params[:id])
    @categories = Category.order('name ASC').collect do |category|
      [category.name , category.id]
    end

    @manufacturers = Manufacturer.order('name ASC').collect do |manu|
      [manu.name , manu.id]
    end

    @projects = Project.order('name ASC').collect do |project|
      [project.name , project.id]
    end

    @donors = Donor.order('name ASC').collect do |donor|
      [donor.name , donor.id]
    end

    @status = StateType.order('name ASC').collect do |state|
      [state.name , state.id]
    end

    @suppliers = Supplier.order('name ASC').collect do |supplier|
      [supplier.name , supplier.id]
    end

    @location = Site.order('name ASC').collect do |site|
      [site.name , site.id]
    end
    
    @currencies = Currencies.order('code ASC').collect do |currency|
      [currency.code , currency.id]
    end

  end

  def update
    Item.transaction do
      item = Item.find(params[:id])
      item.name = params[:asset]['name']
      item.category_type = params[:asset]['category']
      item.brand = params[:asset]['manufacturer']
      item.version = params[:asset]['version']
      item.serial_number = params[:asset]['serial_num']
      item.vendor = params[:vendor]['supplier']
      item.model = params[:asset]['model']
      item.project_id = params[:work]['project']
      item.donor_id = params[:work]['donor']
      item.purchased_date = params[:vendor]['date_of_invoice'].to_date
      item.order_number = params[:vendor]['invoice_num']
      item.current_quantity = params[:vendor]['quantity']
      item.bought_quantity = params[:vendor]['quantity']
      item.cost = params[:vendor]['cost']
      item.currency_id = params[:vendor]['currency'].to_i
      item.date_of_receipt = params[:organisation]['receipt_date'].to_date
      item.delivered_by = params[:organisation]['delivered_by']
      item.status_on_delivery = params[:organisation]['delivery_status']
      item.location = params[:organisation]['location']

      asset_expiry_date = (params[:asset]['expiry_date']).to_date rescue nil
      if asset_expiry_date
        item.expiry_date = asset_expiry_date
      end

      if item.save 
        curr_state = ItemState.where(:'item_id' => item.id)[0]                                  
        curr_state.current_state = StateType.find(params[:organisation]['current_status']).id            
        curr_state.save 
        flash[:notice] = 'Successfully updated.'                                  
      else                                                                        
        flash[:error] = 'Something went wrong - did not create.'                  
      end
    end
    redirect_to asset_details_url(:id => params[:id])
  end

  def delete
    asset = Item.find(params[:id])
    asset.voided = true
    asset.void_reason = 'removed by user'
    asset.save
    redirect_to '/asset_search'
  end

  def search_categories
    @categories = Category.order('name DESC')
  end

  def show_asset_category
    @category = Category.find(params[:id])
    if request.post?
      @category.name = params[:category]['name']                                         
      @category.abbreviation = params[:category]['abv'] unless params[:category]['abv'].blank?
      @category.description = params[:category]['description'] unless params[:category]['description'].blank?
      @category.save
      redirect_to '/asset_categories' and return
    end
  end

  def delete_asset_category
    @category = Category.find(params[:id])
    @category.voided = true
    @category.void_reason = 'removed by user'
    @category.save
    redirect_to '/asset_categories' 
  end

  def states_search
    @states = StateType.order('name DESC')
  end

  def edit_asset_state
    @state = StateType.find(params[:id])                                                    
    if request.post?
      @state.name = params[:state]['name']                                         
      @state.description = params[:state]['description'] unless params[:state]['description'].blank?
      @state.save
      redirect_to '/asset_states_search' 
    end
  end

  def delete_asset_state
    state = StateType.find(params[:id])
    state.voided = true
    state.void_reason = 'removed by user'
    state.save
    redirect_to '/asset_states_search' 
  end

  def live_search
    render :text => get_datatable(params[:search_str]) and return
  end

  def serial_number_generator
    render :text => get_serial_number and return
  end

  private                           
  
  def get_serial_number
    chars = ('A'..'Z').to_a + (0..9).to_a
    size = 16
    return (0...size).collect { chars[Kernel.rand(chars.length)] }.join
  end
  
  def get_datatable(search_str)
    @html =<<EOF
      <table id="search_results" class="table table-striped table-bordered table-condensed">
        <thead>                                                                       
          <tr id = 'table_head'>                                                        
            <th id="th1" style="width:200px;">Serial number</th>                        
            <th id="th3" style="width:200px;">Name</th>                                 
            <th id="th4" style="width:200px;">Category</th>                             
            <th id="th5" style="width:200px;">Brand</th>                                
            <th id="th8" style="width:150px;">Quantity</th>                             
            <th id="th10" style="width:100px;">&nbsp;</th>                              
          </tr>                                                                         
        </thead>                                                                      
        <tbody id='results'>
EOF

     brand_ids = Manufacturer.where("name LIKE ('#{search_str}%%')").map(&:id)
     brand_ids = [0] if brand_ids.blank?
      
     items = Item.order("name ASC").where("name LIKE ('%#{search_str}%')
     OR serial_number LIKE ('%#{search_str}%') OR description LIKE ('%#{search_str}%')
     OR brand IN (#{brand_ids.join(',')}) OR version LIKE ('%#{search_str}%')
     OR model LIKE ('%#{search_str}%') OR vendor LIKE ('%#{search_str}%')").limit(100)

     (items || []).each do |item|
       asset = get_asset(item.id)
       @html +=<<EOF
          <tr>                                                                        
            <td>#{asset[:serial_number]}</td>                                       
            <td>#{asset[:name]}</td>                                                
            <td>#{asset[:category]}</td>                                            
            <td>#{asset[:brand]}</td>                                               
            <td>#{asset[:current_quantity]}</td>                                            
            <td><a href="#{asset_details_url(:id => item.id)}">Show</a></td>       
          </tr>
EOF
     end

       @html +=<<EOF
         </tbody>                                                                      
  </table>
EOF

    return @html
  end
                                              
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create' or 
        action_name == 'new_category' or action_name == 'create_category' or
        action_name == 'create_state' or action_name == 'new_state'
      unless admin?                                                             
        redirect_to '/assets'                                            
      end                                                                       
    end                                                                         
  end

  def get_asset(asset_id)
    asset = Item.find(asset_id)
    @asset = {}
    @asset[asset.id] = {
      :name => asset.name,
      :category => Category.find(asset.category_type).name,
      :brand => Manufacturer.find(asset.brand).name,
      :version => asset.version,
      :model => asset.model,
      :serial_number => asset.serial_number,
      :supplier => Supplier.find(asset.vendor).name,
      :project => Project.find(asset.project_id).name,
      :donor => Donor.find(asset.donor_id).name,
      :purchased_date => asset.purchased_date.strftime('%d %B %Y'),
      :order_number => asset.order_number,
      :current_quantity => asset.current_quantity,
      :bought_quantity => asset.bought_quantity,
      :cost => asset.cost,
      :date_of_receipt => asset.date_of_receipt.strftime('%d %B %Y'),
      :delivered_by => asset.delivered_by,
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,
      :location => Site.find(asset.location).name , 
      :asset_id => asset.id,
      :expiry_date => asset.expiry_date,
      :current_state => StateType.find(asset.current_state.current_state).name
    }
  end

end
