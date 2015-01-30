


def start
  Spreadsheet.client_encoding = 'UTF-8'
  categories = []
  donors = []
  manufacturers = []
  projects = []
  suppliers = []
  sites = []

  donors_hash = {}
  manufacturers_hash = {}
  projects_hash = {}
  suppliers_hash = {}
  categories_hash = {}
  site_hash = {}

  donor_project = {}
  category_type = {}

  assets = {}
  dispatched_hash = {}

  book = Spreadsheet.open("/var/www/xInventory/data.ods").worksheet 0
  icount = 0
  (book.rows || []).each_with_index do |row, i|
    next if i < 1
    next if row[0].blank?
    if row[0].match(/monitor/i)
      category = 'Monitor'
    elsif row[0].match(/Touchscreen/i)
        category = 'Computer'
    elsif row[0].match(/monitor/i)
          category = 'Monitor'
    elsif row[0].match(/Flat screen/i)
        category = 'Monitor'
    elsif row[0].match(/Printer/i)
      category = 'Printer'
    elsif row[0].match(/Battery charger/i)
      category = 'Power Accessories'
    elsif row[0].match(/Router/i)
      category = 'Network Accessories'
    elsif row[0].match(/Inverter/i)
      category = 'Power Accessories'
    elsif row[0].match(/EngEnius Access Point/i)
      category = 'Network Accessories'
    elsif row[0].match(/routerboard/i)
      category = 'Network Accessories'
    elsif row[0].match(/router board/i)
      category = 'Network Accessories'
    elsif row[0].match(/scanner/i)
      category = 'Scanner'
    elsif row[0].match(/lvd/i)
      category = 'Power Accessories'
    elsif row[0].match(/Network switch/i)
      category = 'Network Accessories'
    elsif row[0].match(/tablet/i)
      category = 'Tablet'
    else
      category = row[0].squish.titleize rescue 'Unknown'
    end rescue category = 'Unknown'

    if row[8].match(/lighthouse/i)
      donor = 'Lighthouse'
    elsif row[8].squish.titleize.upcase == 'LH'
      donor = 'Lighthouse'
    else
      donor = row[8].squish.titleize rescue 'Unknown'
    end rescue donor = 'Unknown'

    if row[5].match(/Storeroom/i)
      site = 'Storeroom (LL)'
    else
      site = row[5].squish.titleize rescue 'Unknown'
    end rescue site = 'Unknown'

    manufacturer =  row[2].squish.titleize rescue 'Unknown'
    project = row[9].squish.titleize rescue 'Unknown'
    supplier = row[4].squish.titleize rescue 'Unknown'

    categories << category
    manufacturers << manufacturer
    donors << donor
    projects << project
    suppliers << supplier
    sites << site

    asset_name = row[0].titleize.squish
    asset_id = (icount+= 1)

    donor_project[project] = donor
    category_type[asset_name] = category

    donors_hash[asset_id] = donor
    manufacturers_hash[asset_id] = manufacturer
    projects_hash[asset_id] = project
    suppliers_hash[asset_id] = supplier
    categories_hash[asset_id] = category
    site_hash[asset_id] = site

    serial_number = row[1].to_s.upcase rescue 'Unknown'
    cost = row[13].to_f rescue 0.00
    invoice_date = row[15].to_date rescue nil
    collected = row[11].squish.titleize rescue nil
    condition = row[10].squish.titleize rescue 'Unknown'
    documentation = row[14].titleize rescue nil
    model = row[3].squish.upcase rescue 'Unknown'
    dispatched_date = row[6].to_date rescue nil

    assets[asset_id] = {
      :name => asset_name, :donor => donor, :project => project,
      :category => category, :manufacturer => manufacturer,
      :supplier => supplier,:current_location => site,
      :condition => condition,:collected => collected,:notes => row[13],
      :doc => documentation, :invoice_date => invoice_date, :cost => cost,
      :serial_number => serial_number,:model => model
    }
    dispatched_hash[asset_id] = {
      :site => site,:doc => documentation,:dispatched_date => dispatched_date,
      :notes => row[13],:collected => collected,:condition => condition
    }
  end

  categories = categories.uniq
  donors = donors.uniq
  manufacturers = manufacturers.uniq
  projects = projects.uniq
  suppliers = suppliers.uniq
  sites = sites.uniq

  (donors || []).each do |name|
    donor = Donor.new()
    donor.name = name.titleize
    donor.save
    puts "donor:  #{name.titleize}"
  end

  (projects || []).each do |name|
    puts ">>>:  #{name.titleize}"
    project = Project.new()
    project.name = name.titleize
    project.donor_id = get_project(name,donor_project).id
    project.save
    puts "projects:  #{name.titleize}"
  end

  (manufacturers || []).each do |name|
    manu = Manufacturer.new()
    manu.name = name.titleize
    manu.save
    puts "Manufacturers:  #{name.titleize}"
  end

  (categories || []).each do |name|
    cat = Category.new()
    cat.name = name.titleize
    cat.save
    puts "Categories:  #{name.titleize}"
  end

  (suppliers || []).each do |name|
    supplier = Supplier.new()
    supplier.name = name.titleize
    supplier.save
    puts "Suppliers:  #{name.titleize}"
  end

  (sites || []).each do |name|
    next if name.match(/Storeroom/i)
    site = Site.new()
    site.name = name.titleize
    site.save
    puts "Site:  #{name.titleize}"
  end

  baobab_office = Site.where(:name => 'Storeroom (LL)')[0].id

  asset_count = assets.length
  (assets || []).each do |asset_id, attr|
    Item.transaction do
      item = Item.new()
      item.id = asset_id
      item.name = attr[:name].titleize
      item.category_type = Category.where("name = ?", attr[:category])[0].id
      item.brand = Manufacturer.where("name = ?", attr[:manufacturer])[0].id
      item.version = 'Unknown'
      item.serial_number = validate_serial_number(attr[:serial_number])
      item.vendor = Supplier.where("name = ?", attr[:supplier])[0].id
      item.model = attr[:model]
      item.project_id = Project.where("name = ?", attr[:project])[0].id
      item.donor_id = Donor.where("name = ?", attr[:donor])[0].id
      item.purchased_date = '2000-01-01'.to_date
      item.order_number = "Unknown"
      item.current_quantity = 1
      item.bought_quantity = 1
      item.cost = attr[:cost]
      item.currency_id = 2
      item.date_of_receipt = '2000-01-01'.to_date
      item.delivered_by = "Unknown"
      item.status_on_delivery = StateType.where(:name => attr[:condition])[0].id
      item.location = baobab_office
      item.barcode = assign_barcode

      if item.save
        curr_state = ItemState.new()
        curr_state.item_id = item.id
        curr_state.current_state = StateType.where(:name => attr[:condition])[0].id
        curr_state.save
      end
      puts "..............................#{asset_count -= 1}"
    end
  end



  #dispatched items.

  (dispatched_hash || []).each do |asset_id, attr|
    next if attr[:site] == 'Storeroom'
    item = Item.find(asset_id) rescue nil
    next if item.blank?

    dispatched_asset(item, attr[:dispatched_date], 'Unknown', attr[:site], 1, attr[:notes])
    puts "dispatched asset ......... #{item.name}"
  end

end

def dispatched_asset(item,date_dispatched, dispatcher, location, quantity, reason)
  DispatchReceive.transaction do
    asset = item
    dispatch = DispatchReceive.new()
    dispatch.asset_id = asset.id
    dispatch.transaction_type = DispatchReceiveType.find_by_name('Dispatch').id
    dispatch.encounter_date = date_dispatched.to_date rescue Date.today
    dispatch.approved_by = "User One"
    dispatch.responsible_person = dispatcher
    dispatch.location_id = get_location(location)
    asset.location = dispatch.location_id
    dispatch.quantity = quantity
    unless reason.blank?
      dispatch.reason = reason
    end

    if dispatch.save
      asset.save
      curr_state = ItemState.where(:'item_id' => asset.id).first
      curr_state.current_state = StateType.where("name ='Good Condition'").last.id
      curr_state.save

      asset.current_quantity -= dispatch.quantity
      asset.current_quantity = 0 if asset.current_quantity < 0
      asset.save
    end

  end

end

def get_location(name)
  Site.where("name = ?", name).first.id rescue 1
end

def get_project(project_name,donor_project)
  donor = donor_project[project_name]
  Donor.where("name = ?",donor).first
end

def assign_barcode
  last_barcode = Item.select("MAX(barcode) barcode")[0].try(:barcode) || 'BHT'
  number = last_barcode.sub("BHT",'').to_i
  return "BHT#{(number + 1).to_s.rjust(6,"0")}"
end

def validate_serial_number(serial_number)
  i = Item.where(:serial_number => serial_number)
  return serial_number if i.blank?

  chars = ('A'..'Z').to_a + (0..9).to_a
  size = 16
  return (0...size).collect { chars[Kernel.rand(chars.length)] }.join
end


start
