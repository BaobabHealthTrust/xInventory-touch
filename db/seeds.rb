# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

site = Site.new()
site.name = 'Baobab Health Trust (LL)'
site.description = "Baobab's head office located in Lilongwe city in area 3"
site.save
         
site = Site.new()
site.name = 'Baobab Health Trust (BT)'
site.description = 'Baobab regional branch located in Blantyre city - Mandala'         
site.save
                                   
type = DispatchReceiveType.new()
type.name = 'Dispatch'
type.description = 'Process of dispatching assets'         
type.save
                                   
type = DispatchReceiveType.new()
type.name = 'Receive'
type.description = 'Process of receiving assets'         
type.save
                                             
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
