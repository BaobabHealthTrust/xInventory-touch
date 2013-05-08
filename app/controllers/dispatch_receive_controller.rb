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
    @asset = get_asset(params[:id])

    @status = StateType.order('name ASC').collect do |state|                    
      [state.name , state.id]                                                   
    end
    
    @location = Site.order('name ASC').collect do |site|                        
      [site.name , site.id]                                                     
    end 

  end  

  def receive_asset
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
    raise params.to_yaml
  end

  private   

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
      :quantity => asset.quantity,                                              
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
      :quantity => asset.quantity,                                              
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
        :quantity => asset.quantity,                                            
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
