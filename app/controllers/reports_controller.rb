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

  def advanced_stock_balances_search  
    start_date = params[:start_date].to_date rescue nil
    end_date = params[:end_date].to_date rescue nil
    
    if start_date.blank? or end_date.blank?
      render :text => '' and return 
    elsif start_date > end_date
      render :text => '' and return 
    end

    donor = params[:donor].to_i rescue 0 
    project = params[:project].to_i rescue 0
    category = params[:category].to_i rescue 0
    name = params[:name] 

    donor = nil if donor < 1
    project = nil if project < 1
    category = nil if category < 1

    render :text => get_stock_balance_adnvanced(start_date,end_date,
      donor,project,category,name) and return
  end

  def advanced_stock_balances
    @categories = Category.order('name ASC').collect do |category|              
      [category.name , category.id]                                             
    end                                                                         
                                                                                
    @projects = Project.order('name ASC').collect do |project|                  
      [project.name , project.id]                                               
    end                                                                         
                                                                                
    @donors = Donor.order('name ASC').collect do |donor|                        
      [donor.name , donor.id]                                                   
    end

    @assets = Item.group(:name).order('name ASC').collect do |asset|                        
      [asset.name , asset.name]                                                   
    end

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
    if donor > 0 
      data = Item.where("donor_id = ? AND purchased_date >= ? AND purchased_date <= ?",
        donor,start_date,end_date).order("purchased_date DESC,name ASC")
    else
      data = Item.where("purchased_date >= ? AND purchased_date <= ?",
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

  def get_stock_balance_adnvanced(start_date,end_date,donor = nil , project = nil,category = nil,name=nil)
    @categories = {}

    if not donor.blank? and not project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ? AND project_id = ? 
        AND category_type = ?)",start_date,end_date,donor,project,category)
    elsif not donor.blank? and project.blank? and category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ?)",start_date,end_date,donor)
    elsif not donor.blank? and not project.blank? and category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ? AND project_id = ?)",
        start_date,end_date,donor,project)
    elsif not donor.blank? and project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ? AND category_type = ?)",
        start_date,end_date,donor,category)
    elsif donor.blank? and not project.blank? and category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (project_id = ?)",
        start_date,end_date,project)
    elsif donor.blank? and not project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (project_id = ? AND category_type = ?)",
        start_date,end_date,project,category)
    elsif not donor.blank? and not project.blank? and category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ? AND project_id = ?)",
        start_date,end_date,donor,project_id)
    elsif donor.blank? and project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (category_type = ?)",
        start_date,end_date,category)
    elsif donor.blank? and not project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (project_id = ? AND category_type = ?)",
        start_date,end_date,project_id,category)
    elsif not donor.blank? and project.blank? and not category.blank? and name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (donor_id = ? AND category_type = ?)",
        start_date,end_date,donor,category)



    elsif donor.blank? and project.blank? and category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ?)",start_date,end_date,name)
    elsif donor.blank? and project.blank? and not category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND category_type = ?)",
        start_date,end_date,name,category)
    elsif donor.blank? and not project.blank? and category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND project_id = ?)",
        start_date,end_date,name,project)
    elsif not donor.blank? and project.blank? and category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND donor_id = ?)",
        start_date,end_date,name,donor)
    elsif donor.blank? and not project.blank? and not category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND project_id = ? AND category_type = ?)",
        start_date,end_date,name,project,category)
    elsif not donor.blank? and project.blank? and not category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND donor_id = ? AND category_type = ?)",
        start_date,end_date,name,donor,category)
    elsif not donor.blank? and not project.blank? and not category.blank? and not name == 'All (asset name)'
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=? AND (name = ? AND donor_id = ? AND project_id = ?
        AND category_type =?)",start_date,end_date,name,donor,project,category)















    else
      assets = Item.where("purchased_date >= ? 
        AND purchased_date <=?",start_date,end_date)

    end

    (assets || []).each do |asset|
      if  @categories[asset.category.name].blank?
        @categories[asset.serial_number] = {
          :bought => asset.bought_quantity , :category => asset.category.name,
          :current_quantity => asset.current_quantity , :asset_name => asset.name, 
          :donor => asset.donor.name, :project => asset.project.name
        } 
      end

    end

    @html =<<EOF
  <table id='search_results' class='table table-striped table-bordered table-condensed'>
  <thead>                                                                       
  <tr id = 'table_head'>                                                        
    <th id="th3" style="width:200px;">Serial number</th>                                 
    <th id="th3" style="width:200px;">Item</th>                                 
    <th id="th3" style="width:200px;">Category</th>                                 
    <th id="th3" style="width:200px;">Donor</th>                                 
    <th id="th3" style="width:200px;">Project</th>                                 
    <th id="th1" style="width:200px;">Bought</th>                        
    <th id="th5" style="width:200px;">Balance</th>                                
  </tr>                                                                         
  </thead>                                                                      
  <tbody id='results'>  
EOF

    bought_total = 0 ; balance_total = 0

    (@categories || {}).each do | serial_number , values |  
    bought_total+= values[:bought]
    balance_total+= values[:current_quantity]
    @html +=<<EOF
      <tr>                                                                        
      <td>#{serial_number}</td>                                       
      <td>#{values[:asset_name]}</td>                                       
      <td>#{values[:category]}</td>                                       
      <td>#{values[:donor]}</td>                                       
      <td>#{values[:project]}</td>                                       
      <td>#{values[:bought]}</td>                                       
      <td>#{values[:current_quantity]}</td>                                       
    </tr>
EOF
    end

    @html +=<<EOF
        <tr>                                                                        
          <td style="font-weight:bold;font-size:14px;">Total</td>                                       
          <td>&nbsp;</td>                                       
          <td>&nbsp;</td>                                       
          <td>&nbsp;</td>                                       
          <td>&nbsp;</td>                                       
          <td style="font-weight:bold;font-size:14px;">#{bought_total}</td>                                       
          <td style="font-weight:bold;font-size:14px;">#{balance_total}</td>                                       
        </tr>
      </tbody>                                                                      
  </table>                                                                      
EOF

    return @html
  end 
  
end
