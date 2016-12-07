class AssetsController < ApplicationController
  before_filter :check_authorized

  def index
    @page_title = "<h1>assets <small>....</small></h1>"
    render :layout => 'imenu'
  end

  def find_by_barcode
    @item = Item.where("(barcode = ? OR serial_number = ?)",
      params[:barcode],params[:barcode])[0] rescue nil

    if @item
      redirect_to :action => :show, :id => @item.id
    else
      redirect_to :action => :index
    end
  end

  def show
    @asset = get_asset(params[:id])
    responsible_person = Item.find(params[:id]).responsible_person
    @status = StateType.order('name ASC').collect do |state|
      [state.name , state.id]
    end

    @page_title = "#{@asset[:name]}<br />"
    @page_title += "Location:&nbsp;#{@asset[:location]}"
    unless responsible_person.blank?
      @page_title += "&nbsp;&nbsp;Responsible person:&nbsp;#{responsible_person}"
    end
    render :layout => 'imenu'
  end

  def search_results
    @assets = []
    (Item.where("id IN(?)",params[:id].split(','))|| []).each do |item|
      @assets << get_asset(item.id)
    end
    @page_title = "<h1>Found assets</h1>"
    render :layout => 'imenu'
  end

  def search
    if request.post?
      asset_ids = Item.where("serial_number = ? OR barcode = ?",
        params[:identifier],params[:identifier]).map(&:id)

      if asset_ids.length == 1
        if params[:dispatching] == 'true'
          redirect_to :controller => :dispatch_receive,
            :action => :find_asset_to_dispatch_by_barcode,
            :barcode => Item.find(asset_ids.first).serial_number
        elsif params[:transferring] == 'true'
          redirect_to :controller => :dispatch_receive,
            :action => :find_asset_to_dispatch_by_barcode,:transferring => true,
            :barcode => Item.find(asset_ids.first).serial_number
        elsif params[:receiving] == 'true'
          redirect_to :controller => :dispatch_receive,
            :action => :find_asset_to_return_by_barcode,:receiving => true,
            :barcode => Item.find(asset_ids.first).serial_number
        elsif not params[:reimbursing].blank?
          redirect_to :controller => :dispatch_receive,
            :action => :find_asset_to_dispatch_by_barcode,:reimbursing => params[:reimbursing],
            :barcode => Item.find(asset_ids.first).serial_number
        else
          redirect_to :action => :show, :id => asset_ids.first
        end
        return
      elsif asset_ids.length > 1
        if params[:dispatching] == 'true'
          redirect_to :action => :search_results, :dispatching => true,
            :id => asset_ids[0..99].join(',')
        elsif params[:transferring] == 'true'
          redirect_to :action => :search_results, :transferring => true,
            :id => asset_ids[0..99].join(',')
        elsif params[:receiving] == 'true'
          redirect_to :action => :search_results, :receiving => true,
            :id => asset_ids[0..99].join(',')
        elsif not params[:reimbursing].blank?
          redirect_to :action => :search_results, :reimbursing => params[:reimbursing],
            :id => asset_ids[0..99].join(',')
        else
          redirect_to :action => :search_results, :id => asset_ids[0..99].join(',')
        end
        return
      else
        @notfound  = true
        if params[:dispatching] == 'true'
          redirect_to :action => :search, :dispatching => true
        elsif params[:transferring] == 'true'
          redirect_to :action => :search, :transfer => true
        elsif params[:receiving] == 'true'
          redirect_to :action => :search, :receiving => true
        elsif not params[:reimbursing].blank?
          redirect_to :action => :search, :reimbursing => params[:reimbursing]
        end
      end
    end
    @page_title = "<h1>Find assets <small>....</small></h1>"
    #render :layout => 'top_bottom_menu'
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
    item = Item.where("serial_number = ?", params[:asset]['serial_num'])
    if item.blank?
    Item.transaction do
      item = Item.new()
      item.name = params[:asset]['name']
      item.category_type = params[:asset]['category']
      item.brand = params[:asset]['manufacturer']
      item.version = params[:asset]['version'].to_s rescue ""
      item.serial_number = params[:asset]['serial_num']
      item.vendor = params[:vendor]['supplier']
      item.model = params[:asset]['model']
      item.project_id = params[:work]['project']
      item.donor_id = params[:work]['donor']
      item.purchased_date = params[:vendor]['date_of_invoice'].to_date rescue Date.new(1900,01,01)
      item.order_number = params[:vendor]['invoice_num']
      item.current_quantity = params[:vendor]['quantity']
      item.bought_quantity = params[:vendor]['quantity']
      item.cost = params[:vendor]['cost']
      item.currency_id = params[:vendor]['currency'].to_i
      item.date_of_receipt = params[:organisation]['receipt_date'].to_date rescue Date.new(1900,01,01)
      item.delivered_by = params[:organisation]['delivered_by']
      item.status_on_delivery = params[:organisation]['delivery_status']
      item.location = params[:organisation]['location']
      item.barcode = assign_barcode  #method call


      asset_lifespan = (params[:asset]['lifespan']).to_i rescue 0
      if asset_lifespan > 0
        item.expiry_date = (Date.today + asset_lifespan.year)
      end

      if item.save
        curr_state = ItemState.new()
        curr_state.item_id = item.id
        curr_state.current_state = StateType.find(params[:organisation]['current_status']).id
        curr_state.save
        print_and_redirect("/barcode_print/#{item.id}", "/asset_details/#{item.id}") and return
      else
        flash[:error] = 'Something went wrong - did not create.'
      end
    end
  else
    flash[:error] = 'Something went wrong - did not create.'
  end

    redirect_to '/assets'
  end

  def print_barcode
    print_string = Item.find(params[:id]).barcode_label
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
      :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def print_asset_barcode
    print_and_redirect("/barcode_print/#{params[:id]}", "/asset_details/#{params[:id]}") and return
  end

  def new_category
    @page_title = "<h1>Create Asset Category</h1>"
    #render :layout => 'top_bottom_menu'
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

    redirect_to '/assets'
  end

  def new_state
    @page_title = "<h1>Create asset state</h1>"
    #render :layout => 'top_bottom_menu'
  end

  def validate_category
    render :text => name_validator(params[:id]) and return
  end

  def validate_state
    render :text => state_validator(params[:id]) and return
  end

  def state_validator(name)
    name = StateType.where(:'name' => name)
    return ! name.blank? ? true : false
  end

  def name_validator(name)
    name = Category.where(:'name' => name)
    return ! name.blank? ? true : false
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
    redirect_to '/assets'
  end

  def edit
    @asset = get_asset(params[:id])
    asset = Item.find(@asset[:asset_id])

    @fields = [
      ["Name: #{@asset[:name]}","name"],
      ["Serial number: #{@asset[:serial_number]}","serial_number"], ["Model: #{@asset[:model]}","model"],
      ["Version: #{@asset[:version]}","version"],["Category: #{@asset[:category]}","category"],
      ["Manufacturer: #{@asset[:brand][0..23]}","manufacturer"],
      ["Expiry date: #{asset.expiry_date}","lifespan"],
      ["Project: #{@asset[:project]}","project"],["Donor: #{@asset[:donor]}","donor"],
      ["Supplier: #{@asset[:supplier]}","supplier"],
      ["Invoice number: #{@asset[:order_number]}","invoice_number"],
      ["Invoice date: #{@asset[:purchased_date]}","invoice_date"],
      ["Bought quantity: #{@asset[:bought_quantity]}","quantity"],
      ["Cost: #{@asset[:cost]} (#{asset.currency.code})","cost"],
      ["Date of receipt #{@asset[:date_of_receipt]}","date_of_receipt"],
      ["Delivered by: #{@asset[:delivered_by]}","delivered_by"],
      ["Delivered status #{@asset[:status_on_delivery]}","delivery_status"],
      ["Current status: #{@asset[:current_state]}","current_status"],
      ["Current Location: #{@asset[:location]}","store_room"]
    ]
     # ["Store room: #{@asset[:location]}","store_room"]

    @page_title =<<EOF
    <h3>Edit:&nbsp;<a href="#" onmousedown="editAttribute('name')">#{@asset[:name]}</a></h3>
EOF
    render :layout => 'imenu'
  end

  def tedit
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

    @asset_id = params[:id]
    @attr_to_edit = params[:par]
  end

  def update
    if request.post?
      Item.transaction do
        item = Item.find(params[:asset_id])
        unless params[:asset].blank?
          item.name = params[:asset]['name'] unless params[:asset]['name'].blank?
          item.category_type = params[:asset]['category'] unless params[:asset]['category'].blank?
          item.brand = params[:asset]['manufacturer'] unless params[:asset]['manufacturer'].blank?
          item.version = params[:asset]['version'] unless params[:asset]['version'].blank?
          item.serial_number = params[:asset]['serial_num'] unless params[:asset]['serial_num'].blank?
          item.model = params[:asset]['model'] unless params[:asset]['model'].blank?

          asset_lifespan = (params[:asset]['lifespan']).to_i rescue 0
          if asset_lifespan > 0
            item.expiry_date = (Date.today + asset_lifespan.year)
          end
        end

        unless params[:vendor].blank?
          item.vendor = params[:vendor]['supplier'] unless params[:vendor]['supplier'].blank?
          item.purchased_date = params[:vendor]['date_of_invoice'].to_date unless params[:vendor]['date_of_invoice'].blank?
          item.order_number = params[:vendor]['invoice_num'] unless params[:vendor]['invoice_num'].blank?
          unless params[:vendor]['quantity'].blank?
            original_bought_quantity = item.bought_quantity
            if original_bought_quantity.to_f > params[:vendor]['quantity'].to_f
              item.bought_quantity = params[:vendor]['quantity']
              item.current_quantity = (original_bought_quantity - item.current_quantity)
            elsif original_bought_quantity.to_f < params[:vendor]['quantity'].to_f
              #Do something
            end
          end
          item.cost = params[:vendor]['cost'] unless params[:vendor]['cost'].blank?
          item.currency_id = params[:vendor]['currency'].to_i unless params[:vendor]['currency'].blank?
        end

        unless params[:work].blank?
          item.project_id = params[:work]['project'] unless params[:work]['project'].blank?
          item.donor_id = params[:work]['donor'] unless params[:work]['donor'].blank?
        end

        unless params[:organisation].blank?
          item.date_of_receipt = params[:organisation]['receipt_date'].to_date unless params[:organisation]['receipt_date'].blank?
          item.delivered_by = params[:organisation]['delivered_by'] unless params[:organisation]['delivered_by'].blank?
          item.status_on_delivery = params[:organisation]['delivery_status'] unless params[:organisation]['delivery_status'].blank?
          item.location = params[:organisation]['location'] unless params[:organisation]['location'].blank?
        end

        if item.save
          unless params[:organisation].blank?
            unless params[:organisation]['current_status'].blank?
              curr_state = ItemState.where(:'item_id' => item.id)[0]
              curr_state.current_state = StateType.find(params[:organisation]['current_status']).id
              curr_state.save
            end
          end
          flash[:notice] = 'Successfully updated.'
        else
          flash[:error] = 'Something went wrong - did not update.'
        end
      end
      redirect_to edit_asset_url(:id => params[:asset_id])
    end
  end

  def delete
    asset = Item.find(params[:id])
    asset.voided = true
    asset.void_reason = 'removed by user'
    asset.save
    redirect_to '/assets'
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

  def validate_serial_number
    render :text => serial_number_validator(params[:id]) and return
  end

  ######################## create a new asset ###############################
  def find_by_approved_by
    @assets = DispatchReceive.where("approved_by LIKE(?)",
      "%#{params[:search_str]}%").group(:approved_by).limit(10).map{|item|[[item.approved_by]]}
    render :text => "<li></li><li>" + @assets.join("</li><li>") + "</li>"
  end

  def approved_by_name
     @assets = DispatchReceive.find_by_sql("
                      SELECT * FROM dispatch_receives d
                      INNER JOIN people p ON p.id = d.approved_by
                      WHERE p.first_name LIKE '%#{params[:search_str]}%'
                      OR p.last_name LIKE '%#{params[:search_str]}%'
                      GROUP BY approved_by").map{| u | "<li value='#{u.approved_by}'>#{u.first_name} #{u.last_name}</li>" }
     render :text => @assets.join('') and return
  end

    def people_by_name
     @assets = Person.find_by_sql("
                      SELECT * FROM people
                      WHERE first_name LIKE '%#{params[:search_str]}%'
                      OR last_name LIKE '%#{params[:search_str]}%'").map{| u | "<li value='#{u.id}'>#{u.first_name} #{u.last_name}</li>" }
     render :text => @assets.join('') and return
  end

  def find_by_delivered_by
    @assets = Item.where("delivered_by LIKE(?)",
      "%#{params[:search_str]}%").group(:delivered_by).limit(10).map{|item|[[item.delivered_by]]}
    render :text => "<li></li><li>" + @assets.join("</li><li>") + "</li>"
  end

  def find_by_version
    @assets = Item.where("version LIKE(?)",
      "%#{params[:search_str]}%").group(:version).limit(10).map{|item|[[item.version]]}
    render :text => "<li></li><li>" + @assets.join("</li><li>") + "</li>"
  end

  def find_by_model
    @assets = Item.where("model LIKE(?)",
      "%#{params[:search_str]}%").group(:model).limit(10).map{|item|[[item.model]]}
    render :text => "<li></li><li>" + @assets.join("</li><li>") + "</li>"
  end

  def find_by_name
    @assets = Item.where("name LIKE(?)",
      "%#{params[:search_str]}%").group(:name).limit(10).map{|item|[[item.name]]}
    render :text => "<li></li><li>" + @assets.join("</li><li>") + "</li>"
  end
  ######################## create a new asset ###############################

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
      unless admin? || superuser?
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
      :location => asset.current_location.name ,
      :asset_id => asset.id,
      :expiry_date => asset.expiry_date,
      :current_state => StateType.find(asset.current_state.current_state).name
    }
  end

  def assign_barcode
    last_barcode = Item.select("MAX(barcode) barcode")[0].try(:barcode) || 'BHT'
    number = last_barcode.sub("BHT",'').to_i
    return "BHT#{(number + 1).to_s.rjust(6,"0")}"
  end

  def serial_number_validator(num)
    serial_num = Item.where(:'serial_number' => num)
    return serial_num.blank? ? true : false
  end

end
