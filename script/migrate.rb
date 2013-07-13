


def start
  categories = []
  donors = []
  manufacturers = []
  projects = []
  suppliers = []
  donor_project = {}
  category_type = {}
  
  csv_text = FasterCSV.read("/home/mwatha/Desktop/items.csv")
  (csv_text || []).each do |line|
    categories << line[5].titleize
    manufacturers << line[6].titleize
    projects << line[9].titleize
    donors << line[10].titleize
    suppliers << line[11].titleize
    donor_project[line[9].titleize] = line[10].titleize
    category_type[line[1].titleize] = line[5].titleize
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
  csv_location = FasterCSV.read("/home/mwatha/Desktop/statuses.csv")
  (csv_location || []).each do |line|
    next if line[5].match(/room/i)
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
      next if line[0].to_i == 0                                                  
      item = Item.new()        
      item.id = line[0].to_i                                                  
      item.name = line[1].titleize                  
      item.category_type = Category.where("name = ?",category_type[item.name])[0].id 
      item.brand = Manufacturer.where("name = ?",line[6].titleize)[0].id                           
      item.version = 'Unkown'                         
      item.serial_number = line[3]
      item.vendor = Supplier.where("name = ?",line[11].titleize)[0].id                                 
      item.model = line[2]                           
      item.project_id = Project.where("name = ?",line[9].titleize)[0].id
      item.donor_id = Donor.where("name = ?",line[10].titleize)[0].id                         
      item.purchased_date = line[17].to_date rescue Date.today          
      item.order_number = "Unkown"
      item.current_quantity = 1
      item.bought_quantity = 1
      item.cost = rand(500.99)
      item.currency_id = 2
      item.date_of_receipt = line[7].to_date rescue Date.today
      item.delivered_by = "Unkown"                
      item.status_on_delivery = status_on_delivery
      item.location = 1
      if item.save                                                              
        curr_state = ItemState.new()                                            
        curr_state.item_id = item.id                                            
        curr_state.current_state = status_on_delivery
        curr_state.save
      end
      puts "asset: #{item.name} ..............................#{count -= 1}"
    end
  end



  #dispatched items.

  csv_location = FasterCSV.read("/home/mwatha/Desktop/statuses.csv")
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
