class DispatchReceiveController < ApplicationController
  skip_before_filter  :verify_authenticity_token , :only => ['asset_transfers','process_transfer']
  before_filter :check_authorized

  def index
  end
  
  def transfer_assets_search
    @assets = get_assets                                                        
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
    
    @locations = Site.order('name ASC').collect do |site|                        
      [site.name , site.id]                                                     
    end 
    
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
          transfer_transaction.to_location = params[:transfer]['location']
          transfer_transaction.save

          #now we up the asset info to reflect the transfer
          asset.project_id = params[:transfer]['project']
          asset.donor_id = params[:transfer]['donor'] 
          asset.location = params[:transfer]['location']
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
    assets = Item.where("id IN(?)",asset_ids)                                                 
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
      :quantity => asset.current_quantity,                                              
      :cost => asset.cost,                                                      
      :date_of_receipt => asset.date_of_receipt.strftime('%d %B %Y'),           
      :delivered_by => asset.delivered_by,                                      
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,     
      :location => Site.find(asset.location).name ,                             
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
      :quantity => asset.current_quantity,                                              
      :cost => asset.cost,                                                      
      :date_of_receipt => asset.date_of_receipt.strftime('%d %B %Y'),           
      :delivered_by => asset.delivered_by,                                      
      :status_on_delivery => StateType.find(asset.status_on_delivery).name,     
      :location => Site.find(asset.location).name ,                             
      :asset_id => asset.id                                                     
    }                                                                           
  end
                                                                         
  def check_authorized                                                          
    unless admin?                                                             
      redirect_to '/home'                                                   
    end                                                                       
  end

  def get_assets
    @assets = {}                                                                
    Item.order('name ASC').each do |asset|                                      
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
    return @assets
  end

end
