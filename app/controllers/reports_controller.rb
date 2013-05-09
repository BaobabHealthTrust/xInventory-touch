class ReportsController < ApplicationController
  def show
  end

  def search_for_dispatched_assets
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_dispatched_assets(start_date,end_date) and return
  end

  def search_for_assets_bought_in
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    render :text => get_assets_bought_in(start_date,end_date) and return
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


  private

  def get_stock_balance(start_date,end_date)

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
  
  def get_dispatched_assets(start_date,end_date)
	type = DispatchReceiveType.where(:'name' => 'Dispatch').last
    data = DispatchReceive.where("transaction_type = ? AND encounter_date >= ?
           AND encounter_date <= ?",type.id,start_date,end_date)

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


  def get_assets_bought_in(start_date,end_date)
    type = DispatchReceiveType.where(:'name' => 'Receive').last
    data = DispatchReceive.where("transaction_type = ? AND encounter_date >= ?
           AND encounter_date <= ?",type.id,start_date,end_date)

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
    <th id="th8" style="width:150px;">Quantity</th>                             
    <th id="th8" style="width:150px;">Cost</th>                             
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>  
EOF

    (data).each do |dispatch|  
      asset = Item.find(dispatch.asset_id)
      asset_name = asset.name
      location = Site.find(dispatch.location_id).name
      purchase_date = asset.purchased_date
      donor = Donor.find(asset.donor_id).name
      project = Project.find(asset.project_id).name
      supplier = Supplier.find(asset.vendor).name
      order_num = asset.order_number
      quantity = asset.quantity
      cost = asset.cost
      asset_model = asset.version
      serial_num = asset.serial_number
      total_cost += cost
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
      <td>#{cost}</td>                                       
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
