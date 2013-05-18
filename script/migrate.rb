


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

  status_on_delivery = StateType.where("name = 'Good condition'")[0].id
  count = csv_text.length

  (csv_text || []).each do |line|
    Item.transaction do                                                         
      item = Item.new()                                                         
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
      item.cost = 0.0
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

  
end


def get_project(project_name,donor_project)
  donor = donor_project[project_name]
  Donor.where("name = ?",donor).first
end












start
