# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)


sites = [['Baobab Health Trust (LL)',"Baobab's head office located in Lilongwe city in area 3"],
 ['Baobab Health Trust (BT)','Baobab regional branch located in Blantyre city - Mandala']
]         

sites.each do |name,description|
  site = Site.new()
  site.name = name
  site.description = description
  site.save
end
                                   
type = DispatchReceiveType.new()
type.name = 'Dispatch'
type.description = 'Process of dispatching assets'         
type.save
                                   
type = DispatchReceiveType.new()
type.name = 'Receive'
type.description = 'Process of receiving assets'         
type.save
                             
asset_states = [
 ['Good condition',nil] ,
 ['Bad condition',nil]  ,            
 ['Stolen',nil] ,    
 ['Damage',nil]  ,            
 ['Went missing in the field',nil]              
]              
                             
asset_states.each do |name,description|
  asset_state = StateType.new()
  asset_state.name = name
  asset_state.save
end                             

currencies = [
['MK','K','Malawi currency'],
['USD','$','US currency'],
['GBP','£','British currency']
]

currencies.each do |code,abbrv,description|
  c = Currencies.new()
  c.code = code
  c.abbreviation = abbrv
  c.description = description
  c.save
end

user_roles = ['admin','superuser','standard']
user_roles.each do |role|
  r = UserRoleType.new()
  r.name = role
  r.save
end


                                             
person = Person.new()
person.first_name = 'Super'
person.last_name = 'User'   
person.save
                           
user = User.new()
user.username = 'admin'
user.password_hash = 'admin'
user.person_id = person.id   
user.save

role = UserRole.new()
role.user_id = user.id
role.role = 'admin'
role.save
                           
puts "Your new user is: admin, password: admin"
