class DispatchReceiveController < ApplicationController
  skip_before_filter  :verify_authenticity_token , :only => ['asset_transfers','process_transfer']
  before_filter :check_authorized

  def index
    render :layout => 'index'
  end

  def reimburse_create
    Reimbursed.transaction do 
      reimburse = Reimbursed.new
      reimburse.transfer_transation_id = params[:transfer_transation]
      reimburse.reimbursed_item_id = params[:selected_asset]
      reimburse.reimbursed_date = Date.today
      if reimburse.save
        selected_asset = TransferTransations.find(params[:transfer_transation])
        selected_asset.returned = true
        if selected_asset.save
          asset = Item.find(params[:selected_asset])
          asset.donor_id = selected_asset.from_donor
          asset.project_id = selected_asset.from_project
          asset.save
        end
      end
    end
    redirect_to "/borrowed_assets" and return
  end

  def reimburse
    transfer_transation = TransferTransations.find(params[:id])
    @borrowed_asset = {                                                     
      :project => Project.find(transfer_transation.from_project).name,                        
      :donor => Donor.find(transfer_transation.from_donor).name,                              
      :asset_id => transfer_transation.asset_id
    }          

    @transfer_transation_id = params[:id]
    asset = Item.find(params[:reimbursed_id])
    @selected_asset = {                                                     
      :name => asset.name,                                                    
      :category => Category.find(asset.category_type).name,                   
      :brand => Manufacturer.find(asset.brand).name,                          
      :version => asset.version,                                              
      :model => asset.model,                                                  
      :serial_number => asset.serial_number,                                  
      :supplier => Supplier.find(asset.vendor).name,                          
      :project => Project.find(asset.project_id).name,                        
      :donor => Donor.find(asset.donor_id).name,                              
      :purchased_date => asset.purchased_date,                                
      :order_number => asset.order_number,                                    
      :quantity => asset.current_quantity,                                    
      :cost => asset.cost,                                                    
      :date_of_receipt => asset.date_of_receipt,                              
      :delivered_by => asset.delivered_by,                                    
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,   
      :location => Site.find(asset.location).name,
      :asset_id => asset.id
    }          

  end

  def asset_list
    @transfer_transation = TransferTransations.find(params[:id])
    @asset = Item.find(@transfer_transation.asset_id)
    @assets = {}

    asset_borrowed = TransferTransations.where("returned = 0").map(&:asset_id)
    asset_borrowed = [0] if asset_borrowed.blank?

    (Item.where("current_quantity > 0 AND category_type = ?", 
    @asset.category_type) || []).each do |asset|
      @assets[asset.id] = {                                                     
        :name => asset.name,                                                    
        :category => Category.find(asset.category_type).name,                   
        :brand => Manufacturer.find(asset.brand).name,                          
        :version => asset.version,                                              
        :model => asset.model,                                                  
        :serial_number => asset.serial_number,                                  
        :supplier => Supplier.find(asset.vendor).name,                          
        :project => Project.find(asset.project_id).name,                        
        :donor => Donor.find(asset.donor_id).name,                              
        :purchased_date => asset.purchased_date,                                
        :order_number => asset.order_number,                                    
        :quantity => asset.current_quantity,                                    
        :cost => asset.cost,                                                    
        :date_of_receipt => asset.date_of_receipt,                              
        :delivered_by => asset.delivered_by,                                    
        :status_on_delivery => StateType.find(asset.status_on_delivery).name,   
        :location => Site.find(asset.location).name                             
      }          
    end
  end

  def borrowed_assets
    @borrowed_assets = get_transferred_assets
  end
  
  def transfer_assets_search
    @assets = get_assets(options = {:current_quantity => "> 0"})                                                        
  end

  def search
    @assets = get_assets                                                        
  end

  def dispatch_asset
    if request.post? and not params[:dispatch_asset].blank?
       asset = Item.find(params[:id])
       dispatch = DispatchReceive.new()
       dispatch.asset_id = asset.id
       dispatch.transaction_type = DispatchReceiveType.find_by_name('Dispatch').id
       dispatch.encounter_date = params[:dispatch]['date']
       dispatch.approved_by = params[:dispatch]['approved_by'] 
       dispatch.responsible_person = params[:dispatch]['collected_by'] 
       dispatch.location_id = params[:dispatch]['location']
       dispatch.quantity = params[:dispatch]['quantity']
       unless params[:dispatch]['reason'].blank?
         dispatch.reason = params[:dispatch]['reason']
       end
       if dispatch.save             
         curr_state = ItemState.where(:'item_id' => asset.id).first    
         curr_state.current_state = StateType.find(params[:dispatch]['status']).id
         curr_state.save

         asset.current_quantity -= dispatch.quantity
         asset.save                                                
         flash[:notice] = 'Successfully dispatched.'                                
       else                                                                      
         flash[:error] = 'Something went wrong - did not dispatch.'                
       end
       redirect_to assets_to_url(:id => 'dispatch')
    end

    @asset = get_asset(params[:id])

    @status = StateType.order('name ASC').collect do |state|                    
      [state.name , state.id]                                                   
    end
    
    @location = Site.order('name ASC').collect do |site|                        
      [site.name , site.id]                                                     
    end 

  end  

  def receive_asset
    if request.post? and not params[:receive_asset].blank?
       asset = Item.find(params[:id])
       dispatch = DispatchReceive.new()
       dispatch.asset_id = asset.id
       dispatch.transaction_type = DispatchReceiveType.find_by_name('Receive').id
       dispatch.encounter_date = params[:receive]['date']
       dispatch.approved_by = params[:receive]['approved_by'] 
       dispatch.responsible_person = params[:receive]['collected_by'] 
       dispatch.location_id = params[:receive]['location']
       dispatch.quantity = params[:receive]['quantity']
       unless params[:receive]['reason'].blank?
         dispatch.reason = params[:receive]['reason']
       end

       if dispatch.save  
         curr_state = ItemState.where(:'item_id' => asset.id).first    
         curr_state = StateType.find(params[:receive]['status']).id
         curr_state.save
                
         asset.current_quantity += dispatch.quantity
         asset.save                                                
         flash[:notice] = 'Successfully received.'                                
       else                                                                      
         flash[:error] = 'Something went wrong - did not received.'                
       end
       redirect_to assets_to_url(:id => 'receive')
    end

    @asset = get_asset(params[:id])

    @status = StateType.order('name ASC').collect do |state|                    
      [state.name , state.id]                                                   
    end
    
    @location = Site.order('name ASC').collect do |site|                        
      [site.name , site.id]                                                     
    end 
  end  

  def asset_transfers
    @status = StateType.order('name ASC').collect do |state|                    
      [state.name , state.id]                                                   
    end
=begin
    @locations = Site.order('name ASC').collect do |site|                        
      [site.name , site.id]                                                     
    end 
=end
     @projects = Project.order('name ASC').collect do |project|                  
      [project.name , project.id]                                               
    end                                                                         
                                                                                
    @donors = Donor.order('name ASC').collect do |donor|                        
      [donor.name , donor.id]                                                   
    end  

    @asset_ids = params[:selected_assets].split(',') rescue [3]
    @assets = get_assets_by_ids(@asset_ids)
  end

  def process_transfer
    asset_ids = params[:assets_ids].split(',')
    Transfer.transaction do
      @transfer = Transfer.new()
      @transfer.transfer_date = params[:transfer]['date']
      @transfer.save
      (asset_ids).each do |assets_id|
        asset = Item.find(assets_id)
        TransferTransations.transaction do
          transfer_transaction = TransferTransations.new()
          transfer_transaction.transfer_id = @transfer.id
          transfer_transaction.asset_id = asset.id
          transfer_transaction.from_project = asset.project_id
          transfer_transaction.from_donor = asset.donor_id
          transfer_transaction.from_location = asset.location
          transfer_transaction.to_project = params[:transfer]['project']
          transfer_transaction.to_donor = params[:transfer]['donor']
          transfer_transaction.save

          #now we up the asset info to reflect the transfer
          asset.project_id = params[:transfer]['project']
          asset.donor_id = params[:transfer]['donor'] 
          asset.save
        end
      end
    end
   
   if @transfer                                                             
     flash[:notice] = 'Successfully transfered.'                                
     redirect_to transfer_results_url(:id => @transfer.id) 
    else                                                                      
      flash[:error] = 'Something went wrong - did not transfer.'                
    end
  end

  def transfer_results
    @results = get_transfer_results(params[:id])
  end

  def live_search
    render :text => get_datatable(params[:search_str],params[:type]) and return
  end

  private   

  def get_transfer_results(transfer_id)
    transfer = Transfer.find(transfer_id)
    results = {}
    (transfer.transfer_transactions || []).each do |trans|  
      results[trans.id] = {
        :name => Item.find(trans.asset_id).name,
        :donor_from => Donor.find(trans.from_donor).name,
        :project_from => Project.find(trans.from_project).name,
        :donor_to => Donor.find(trans.to_donor).name,
        :project_to => Project.find(trans.to_project).name,
      }
    end
    return results 
  end

  def get_assets_by_ids(asset_ids)                                                       
    assets = Item.where("id IN(?)",asset_ids).order("current_quantity DESC,name ASC")                                                 
    @assets = {}                             
    (assets || []).each do |asset|                                    
    @assets[asset.id] = {                                                        
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
      :cost => asset.cost,                                                      
      :date_of_receipt => asset.date_of_receipt.strftime('%d %B %Y'),           
      :delivered_by => asset.delivered_by,                                      
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,     
      :location => Site.find(asset.location).name ,                            
      :expiry_date => asset.expiry_date , 
      :asset_id => asset.id                                                     
    }                 
    end
    return @assets                                                          
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
      :cost => asset.cost,                                                      
      :date_of_receipt => asset.date_of_receipt.strftime('%d %B %Y'),           
      :delivered_by => asset.delivered_by,                                      
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,     
      :location => Site.find(asset.location).name ,                             
      :expiry_date => asset.expiry_date , 
      :asset_id => asset.id                                                     
    }                                                                           
  end
                                                                         
  def check_authorized                                                          
    unless admin?                                                             
      redirect_to '/home'                                                   
    end                                                                       
  end

  def get_assets(options = {})
    @assets = {}             
    if options.blank?                                                   
      assets = Item.order("current_quantity DESC,name ASC").limit(100)                                      
    else
      assets = Item.order("current_quantity DESC,name ASC").where("current_quantity > 0").limit(100)
    end
      
    (assets || []).each do |asset|      
      @assets[asset.id] = {                                                     
        :name => asset.name,                                                    
        :category => Category.find(asset.category_type).name,                   
        :brand => Manufacturer.find(asset.brand).name,                          
        :version => asset.version,                                              
        :model => asset.model,                                                  
        :serial_number => asset.serial_number,                                  
        :supplier => Supplier.find(asset.vendor).name,                          
        :project => Project.find(asset.project_id).name,                        
        :donor => Donor.find(asset.donor_id).name,                              
        :purchased_date => asset.purchased_date,                                
        :order_number => asset.order_number,                                    
        :current_quantity => asset.current_quantity,                                            
        :cost => asset.cost,                                                    
        :date_of_receipt => asset.date_of_receipt,                              
        :delivered_by => asset.delivered_by,                                    
        :status_on_delivery => StateType.find(asset.status_on_delivery).name,   
        :location => Site.find(asset.location).name                             
      }                                                                         
    end
    return @assets
  end

  def get_datatable(search_str,type)
    @html =<<EOF
      <table id="search_results" class="table table-striped table-bordered table-condensed">
        <thead>                                                                       
          <tr id = 'table_head'>                                                        
            <th id="th1" style="width:200px;">Serial number</th>                        
            <th id="th3" style="width:200px;">Name</th>                                 
            <th id="th4" style="width:200px;">Category</th>                             
            <th id="th5" style="width:200px;">Brand</th>                                
            <th id="th8" style="width:150px;">Quantity in store</th>                    
            <th id="th5" style="width:200px;">Donor</th>                                
            <th id="th5" style="width:200px;">Project</th>                              
            <th id="th10" style="width:100px;">&nbsp;</th>
          </tr>                                                                         
        </thead>                                                                      
        <tbody id='results'>
EOF

     brand_ids = Manufacturer.where("name LIKE ('#{search_str}%%')").map(&:id)
     brand_ids = [0] if brand_ids.blank?
      
     items = Item.where("name LIKE ('%#{search_str}%')
     OR serial_number LIKE ('%#{search_str}%') OR description LIKE ('%#{search_str}%')
     OR brand IN (#{brand_ids.join(',')}) OR version LIKE ('%#{search_str}%')
     OR model LIKE ('%#{search_str}%') 
     OR vendor LIKE ('%#{search_str}%')").order("current_quantity DESC,name ASC").limit(100)

     (items || []).each do |item|
       asset = get_asset(item.id)
       if type == 'dispatch'
         if asset[:current_quantity].to_f < 1
           url = nil
           dispatched_receive = nil
         else
           url = dispatch_url(:id => item.id)
           dispatched_receive = type.titleize
         end
       elsif type == 'transfer'
         url = '#'                                                           
         dispatched_receive = "<input id='#{item.id}_' class='assets' type='checkbox' name='#{item.id}[]'>"
       else
         url = receive_url(:id => item.id)
         dispatched_receive = type.titleize
       end
       @html +=<<EOF
          <tr>                                                                        
            <td>#{asset[:serial_number]}</td>                                       
            <td>#{asset[:name]}</td>                                                
            <td>#{asset[:category]}</td>                                            
            <td>#{asset[:brand]}</td>                                               
            <td>#{asset[:current_quantity]}</td>                                            
            <td>#{asset[:donor]}</td>                                               
            <td>#{asset[:project]}</td>                                               
            <td><a href="#{url}">#{dispatched_receive}</a></td>       
          </tr>
EOF
     end

     if not items.blank? and type == 'transfer'
       @html +=<<EOF
        <table style="width: 98%;">                                                   
           <tr>                                                                       
            <td>                                                                      
              <input onclick="submitForm();" type="button" id="signup"                
                class="btn btn-primary signup_btn" value="Start tranfer" style="width:100%;" />
            </td>                                                                     
          </tr>                                                                       
        </table> 
EOF

     end

       @html +=<<EOF
         </tbody>                                                                      
  </table>
EOF

    return @html
  end

  def get_transferred_assets
    transfers = Transfer.joins("INNER JOIN transfer_transations t ON
      t.transfer_id = transfers.id").where("returned = 0").group(:transfer_id)

    return nil if transfers.blank?
    
    @html =<<EOF                                                                
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Serial number</th>                                 
    <th id="th3" style="width:200px;">Item</th>                                 
    <th id="th1" style="width:200px;">Donor - From</th>                               
    <th id="th1" style="width:200px;">Project - From</th>                               
    <th id="th1" style="width:200px;">Current donor</th>                               
    <th id="th1" style="width:200px;">Current project</th>                               
    <th id="th1" style="width:200px;">Date of Transfer</th>                               
    <th id="th1" style="width:200px;">&nbsp;</th>                               
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>                            
EOF
                                                       
    (transfers).each do |transfer| 
      (transfer.transfer_transactions).each do |transaction|
        next if transaction.returned
        @html +=<<EOF                                                               
      <tr>                                                                        
      <td>#{Item.find(transaction.asset_id).serial_number}</td>                                                      
      <td>#{Item.find(transaction.asset_id).name}</td>                                                      
      <td>#{Donor.find(transaction.from_donor).name}</td>                                                      
      <td>#{Project.find(transaction.from_project).name}</td>                                                      
      <td>#{Donor.find(transaction.to_donor).name}</td>                                                      
      <td>#{Project.find(transaction.to_project).name}</td>                                                      
      <td>#{transfer.transfer_date}</td>                                                      
      <td><a href="#{available_asset_list_url(:id => transaction.id)}">Select</a></td>                                                      
    </tr>                                                                       
EOF
      end                                                                         
    end                                                                         
                                                                                
    @html +=<<EOF                                                               
      </tbody>                                                                      
  </table>                                                                      
EOF
                                                                                
    return @html
  end 
end
