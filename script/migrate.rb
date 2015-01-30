
def add_category
  
  categories = [["Monitor",""],
  ["Computer",""],
  ["Printer","20"],
  ["Scanner",""],
  ["Transformer",""],
  ["Battery Charger","10"],
  ["Router",""],
  ["Scale",""],
  ["Access Point",""],
  ["Inverter",""],
  ["Network Switch","10"],
  ["Router Board",""],
  ["Laptop Computer",""],
  ["Server","5"],
  ["Tablet Computer",""]]

  categories.each do |category|
   cat =  Category.where(name: category[0]).first
   cat.minimum = category[1]
   cat.save
  end
end


def start
  categories = []
  donors = []
  manufacturers = []
  projects = []
  suppliers = []


  donors_hash = {}
  manufacturers_hash = {}
  projects_hash = {}
  suppliers_hash = {}
  categories_hash = {}

  donor_project = {}
  category_type = {}


  csv_text = FasterCSV.read('/var/www/xInventory/data.csv',:col_sep => "\t")
  (csv_text || []).each do |line|
    category = line[5].titleize.squish
    category = 'Computer' if category == "Computor"
    categories << category

    manufacturer = line[6].titleize.squish
    if manufacturer.match(/zebra/i)
      manufacturer = 'Zebra Technologies Corporation'
    elsif manufacturer.match(/J2/i)
      manufacturer = 'J2 Retail Systems'
    elsif manufacturer.match(/Symbol/i)
      manufacturer = 'Symbol Technologies Inc'
    end
    manufacturers << manufacturer

    project = line[9].titleize.squish
    if project == 'Cdc'
      project = 'Center For Disease Control'
    elsif project.match(/kch/i)
      project = project.gsub('Kch','KCH')
    elsif project.match(/Opd/i)
      project = project.gsub('Opd','OPD')
      project = project.gsub('opd','OPD')
    elsif project.match(/Cdc/i)
      project = project.gsub('Cdc','CDC')
    elsif project.match(/pih/i)
      project = project.gsub('Pih','PIH')
    elsif project.match(/Mpc/i)
      project = project.gsub('Mpc','MPC')
    elsif project == 'Dm'
      project = 'DM'
    elsif project == 'Dm/Amu5'
      project = 'DM/Amu5'
    elsif project.match(/Qech/i)
      project = project.gsub('Qech','QECH')
    elsif project.match(/Pmtct/i)
      project = project.gsub('Pmtct','PMTCT')
    elsif project == 'Tb Upgrade'
      project = 'TB Upgrade'
    end
    projects << project



    donor = line[10].titleize.squish
    if donor == 'Com'
      donor = "College Of Medicine"
    elsif donor == 'Lh' or donor == 'Ligthouse'
      donor = "Lighthouse"
    elsif donor == 'Pih'
      donor = "Partners In Hope"
    elsif donor == 'Cdc'
      donor = 'Center For Disease Control'
    end
    donors << donor


    supplier = line[11].titleize.squish
    if supplier.match(/Gov/)
      supplier = "Gov Connections"
    elsif supplier.match(/Kipoint/)
      supplier = "Kipoint Enterprise Co. Ltd"
    elsif supplier.match(/Print/)
      supplier = "Print House"
    end
    suppliers << supplier


    asset_name = line[1].titleize.squish
    asset_id = line[0].to_i

    donor_project[project] = donor
    category_type[asset_name] = category

    donors_hash[asset_id] = donor
    manufacturers_hash[asset_id] = manufacturer
    projects_hash[asset_id] = project
    suppliers_hash[asset_id] = supplier
    categories_hash[asset_id] = category
  end

  categories = categories.uniq
  donors = donors.uniq
  manufacturers = manufacturers.uniq
  projects = projects.uniq
  suppliers = suppliers.uniq

  (donors || []).each do |name|
    donor = Donor.new()
    donor.name = name.titleize
    donor.save
    puts "donor:  #{name.titleize}"
  end

  (projects || []).each do |name|
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

  sites = []
  csv_location = FasterCSV.read('/home/mwatha/Desktop/One-up/statuses.csv',:col_sep => "\t")
  (csv_location || []).each do |line|
    next if line[5].match(/room/i)
    next if line[5].match(/Office/i)
    sites << line[5].titleize
  end

  sites = sites.uniq

  (sites || []).each do |name|
    site = Site.new()
    site.name = name.titleize
    site.save
    puts "Site:  #{name.titleize}"
  end

  status_on_delivery = StateType.where("name = 'Good condition'")[0].id
  count = csv_text.length

  (csv_text || []).each do |line|
    Item.transaction do
      asset_csv_file_id = line[0].to_i

      next if line[0].to_i == 0
      item = Item.new()
      item.id = line[0].to_i
      item.name = line[1].titleize
      item.category_type = Category.where("name = ?",categories_hash[asset_csv_file_id])[0].id
      item.brand = Manufacturer.where("name = ?",manufacturers_hash[asset_csv_file_id])[0].id
      item.version = 'Unkown'
      item.serial_number = line[3]
      item.vendor = Supplier.where("name = ?",suppliers_hash[asset_csv_file_id])[0].id
      item.model = line[2]
      item.project_id = Project.where("name = ?",projects_hash[asset_csv_file_id])[0].id
      item.donor_id = Donor.where("name = ?",donors_hash[asset_csv_file_id])[0].id
      item.purchased_date = line[17].gsub('+AC0','').to_date rescue Date.today
      item.order_number = "Unkown"
      item.current_quantity = 1
      item.bought_quantity = 1
      item.cost = rand(500.99)
      item.currency_id = 2
      item.date_of_receipt = line[7].gsub('+AC0','').to_date rescue Date.today
      item.delivered_by = "Unkown"
      item.status_on_delivery = status_on_delivery
      item.location = 1
      if not line[4].blank?
        item.barcode = line[4].upcase
      end

      if item.save
        curr_state = ItemState.new()
        curr_state.item_id = item.id
        curr_state.current_state = status_on_delivery
        curr_state.save
      end
      puts "..............................#{count -= 1}"
    end
  end



  #dispatched items.

  csv_location = FasterCSV.read('/home/mwatha/Desktop/One-up/statuses.csv',:col_sep => "\t")
  (csv_location || []).each do |line|
    next unless line[2].match(/item out/i)
    next if line[1].match(/item/i)
    item = Item.find(line[1]) rescue nil
    next if item.blank?
    dispatched_asset(item,line[4],line[3],line[5],line[8],line[7])
    puts "dispatched asset ......... #{line[1]}"
  end

end

def dispatched_asset(item,date_dispatched,dispatcher,location,quantity,reason)
  DispatchReceive.transaction do
    asset = item
    dispatch = DispatchReceive.new()
    dispatch.asset_id = asset.id
    dispatch.transaction_type = DispatchReceiveType.find_by_name('Dispatch').id
    dispatch.encounter_date = date_dispatched.to_date rescue Date.today
    dispatch.approved_by = "User One"
    dispatch.responsible_person = dispatcher
    dispatch.location_id = get_location(location)
    dispatch.quantity = quantity
    unless reason.blank?
      dispatch.reason = reason
    end

    if dispatch.save
      curr_state = ItemState.where(:'item_id' => asset.id).first
      curr_state.current_state = StateType.where("name ='Good condition'").last.id
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



start

#add_category
