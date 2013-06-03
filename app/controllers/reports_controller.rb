class ReportsController < ApplicationController
  def show
  end

  def list_of_items_bought_in
    @donors = Donor.order("name ASC").collect{|donor|[donor.name,donor.id]}
  end

  def list_of_dispatched_assets
    @donors = Donor.order("name ASC").collect{|donor|[donor.name,donor.id]}
  end

  def stock_balances
    @donors = Donor.order("name ASC").collect{|donor|[donor.name,donor.id]}
  end

  def transfers
    @donors = Donor.order("name ASC").collect{|donor|[donor.name,donor.id]}
  end

  def search_for_dispatched_assets
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    donor = params[:donor].to_i rescue nil
     
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_dispatched_assets(start_date,end_date,donor) and return
  end

  def search_for_assets_bought_in
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    donor = params[:donor].to_i rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_assets_bought_in(start_date,end_date,donor) and return
  end

  def search_for_stock_balances
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_stock_balance(start_date,end_date) and return
  end

  def search_for_transfers
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_transferred_assets(start_date,end_date) and return
  end


  private

  def get_transferred_assets(start_date,end_date)
    transfers = Transfer.where("transfer_date >= ? AND transfer_date <=?",
      start_date,end_date)

    return nil if transfers.blank?
    
    @html =<<EOF                                                                
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Serial number</th>                                 
    <th id="th3" style="width:200px;">Item</th>                                 
    <th id="th1" style="width:200px;">Donor - From</th>                               
    <th id="th1" style="width:200px;">Project - From</th>                               
    <th id="th1" style="width:200px;">Donor - To</th>                               
    <th id="th1" style="width:200px;">Project - To</th>                               
    <th id="th1" style="width:200px;">Densination</th>                               
    <th id="th1" style="width:200px;">Date of Transfer</th>                               
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>                            
EOF
                                                       
    (transfers).each do |transfer| 
      (transfer.transfer_transactions).each do |transaction|
        @html +=<<EOF                                                               
      <tr>                                                                        
      <td>#{Item.find(transaction.asset_id).serial_number}</td>                                                      
      <td>#{Item.find(transaction.asset_id).name}</td>                                                      
      <td>#{Donor.find(transaction.from_donor).name}</td>                                                      
      <td>#{Project.find(transaction.from_project).name}</td>                                                      
      <td>#{Donor.find(transaction.to_donor).name}</td>                                                      
      <td>#{Project.find(transaction.to_project).name}</td>                                                      
      <td>#{Site.find(transaction.to_location).name}</td>                                                      
      <td>#{transfer.transfer_date}</td>                                                      
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

  def get_total_dispatched(category_type,start_date,end_date)
    asset_ids = Item.where("category_type = ? AND purchased_date >= ? 
      AND purchased_date <= ?",category_type,start_date,end_date).map(&:id)

    return 0 if asset_ids.blank?

    DispatchReceive.where("asset_id IN(?) AND encounter_date >= ? 
      AND encounter_date <= ?",asset_ids,start_date,end_date).sum(:quantity)
  end

  def get_total_bought(category_type,start_date,end_date)
    Item.where("category_type = ? AND purchased_date >= ? 
      AND purchased_date <= ?",category_type,start_date,end_date).sum(:bought_quantity)
  end

  def get_stock_balance(start_date,end_date)
    @categories = {}
    assets = Item.group(:category_type).where("purchased_date >= ? 
      AND purchased_date <=?",start_date,end_date)

    (assets || []).each do |asset|
      if  @categories[asset.category.name].blank?
        @categories[asset.category.name] = {:bought => 0 , :dispatched => 0 ,:balance => 0} 
      end

      @categories[asset.category.name][:bought] += get_total_bought(asset.category_type,start_date,end_date)
      @categories[asset.category.name][:dispatched] += get_total_dispatched(asset.category_type,start_date,end_date)
      @categories[asset.category.name][:balance] = (@categories[asset.category.name][:bought] - @categories[asset.category.name][:dispatched])
    end

    @html =<<EOF
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Item</th>                                 
    <th id="th1" style="width:200px;">Bought</th>                        
    <th id="th4" style="width:200px;">Dispatched</th>                             
    <th id="th5" style="width:200px;">Balance</th>                                
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>  
EOF

    (@categories || {}).each do | category , values |  
    @html +=<<EOF
      <tr>                                                                        
      <td>#{category}</td>                                       
      <td>#{values[:bought]}</td>                                       
      <td>#{values[:dispatched]}</td>                                       
      <td>#{values[:balance]}</td>                                       
    </tr>
EOF
    end

    @html +=<<EOF
      </tbody>                                                                      
  </table>                                                                      
EOF

    return @html
  end 
  
  def get_dispatched_assets(start_date,end_date,donor)
    type = DispatchReceiveType.where(:'name' => 'Dispatch').last

    if donor == 0
      data = DispatchReceive.where("transaction_type = ? AND encounter_date >= ?
      AND encounter_date <= ?",type.id,start_date,end_date)
    else
      data = DispatchReceive.joins("INNER JOIN items i ON dispatch_receives.asset_id = i.id").where("transaction_type = ? 
      AND encounter_date >= ? AND encounter_date <= ? AND donor_id = ?",type.id, start_date,end_date,donor)
    end

    return nil if data.blank?
    total_quantity = 0

    @html =<<EOF
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Asset</th>                                 
    <th id="th1" style="width:200px;">Serial number</th>                        
    <th id="th4" style="width:200px;">Model</th>                             
    <th id="th5" style="width:200px;">Purchase date</th>                                
    <th id="th8" style="width:150px;">Donor</th>                             
    <th id="th8" style="width:150px;">Project</th>                             
    <th id="th8" style="width:150px;">Supplier</th>                             
    <th id="th8" style="width:150px;">Order Number</th>                             
    <th id="th8" style="width:150px;">Origin</th>                             
    <th id="th8" style="width:150px;">Dispatched to</th>                             
    <th id="th8" style="width:150px;">Date of dispatch</th>                             
    <th id="th8" style="width:150px;">Quantity</th>                             
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>  
EOF

    (data).each do |dispatch| 
      asset = Item.find(dispatch.asset_id)
      next if asset.blank?
      asset_name = asset.name
      location = Site.find(dispatch.location_id).name
      encounter_date = dispatch.encounter_date
      purchase_date = asset.purchased_date
      donor = Donor.find(asset.donor_id).name
      project = Project.find(asset.project_id).name
      supplier = Supplier.find(asset.vendor).name
      order_num = asset.order_number
      asset_model = asset.version
      quantity = dispatch.quantity
      store = Site.find(asset.location).name
      serial_num = asset.serial_number
      total_quantity += quantity
    @html +=<<EOF
      <tr>                                                                        
      <td>#{asset_name}</td>                                       
      <td>#{serial_num}</td>                                       
      <td>#{asset_model}</td>                                       
      <td>#{purchase_date}</td>                                       
      <td>#{donor}</td>                                       
      <td>#{project}</td>                                       
      <td>#{supplier}</td>                                       
      <td>#{order_num}</td>                                       
      <td>#{store}</td>                                       
      <td>#{location}</td>                                       
      <td>#{encounter_date}</td>                                       
      <td>#{quantity}</td>                                       
    </tr>
EOF
    end

    @html +=<<EOF
        <tfoot>
        <tr>
            <th style="text-align:left;paddding-left:5px;" colspan="11">Total:</th>
            <th>#{total_quantity}</th>
        </tr>
        </tfoot> 
      </tbody>                                                                      
  </table>                                                                      
EOF

    return @html
  end


  def get_assets_bought_in(start_date,end_date,donor)
    unless donor.blank?
      data = Item.where("donor_id = ? AND purchased_date >= ? AND purchased_date <= ?",
        donor,start_date,end_date).order("purchased_date DESC,name ASC")
    else
      data = Item.where("purchased_date >= AND purchased_date <= ?",
        start_date,end_date).order("purchased_date DESC,name ASC")
    end

    return nil if data.blank?
    total_cost = 0

    @html =<<EOF
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Asset</th>                                 
    <th id="th1" style="width:200px;">Serial number</th>                        
    <th id="th4" style="width:200px;">Model</th>                             
    <th id="th5" style="width:200px;">Purchase date</th>                                
    <th id="th8" style="width:150px;">Donor</th>                             
    <th id="th8" style="width:150px;">Project</th>                             
    <th id="th8" style="width:150px;">Supplier</th>                             
    <th id="th8" style="width:150px;">Order Number</th>                             
    <th id="th8" style="width:150px;">Current quantity</th>                             
    <th id="th8" style="width:150px;">Cost</th>                             
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>  
EOF

    (data).each do |asset|  
      asset_name = asset.name
      location = Site.find(asset.location).name
      purchase_date = asset.purchased_date
      donor = Donor.find(asset.donor_id).name
      project = Project.find(asset.project_id).name
      supplier = Supplier.find(asset.vendor).name
      order_num = asset.order_number
      quantity = asset.current_quantity
      cost = asset.cost
      asset_model = asset.version
      serial_num = asset.serial_number
      total_cost += cost
      currency = asset.currency.code
    @html +=<<EOF
      <tr>                                                                        
      <td>#{asset_name}</td>                                       
      <td>#{serial_num}</td>                                       
      <td>#{asset_model}</td>                                       
      <td>#{purchase_date}</td>                                       
      <td>#{donor}</td>                                       
      <td>#{project}</td>                                       
      <td>#{supplier}</td>                                       
      <td>#{order_num}</td>                                       
      <td>#{quantity}</td>                                       
      <td>#{cost}&nbsp;#{currency}</td>                                       
    </tr>
EOF
    end

    @html +=<<EOF
        <tfoot>
        <tr>
            <th style="text-align:left;paddding-left:5px;" colspan="9">Total:</th>
            <th>#{total_cost}</th>
        </tr>
        </tfoot> 
      </tbody>                                                                      
  </table>                                                                      
EOF

    return @html
  end

end
