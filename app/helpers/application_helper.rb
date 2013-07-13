module ApplicationHelper
  def app_name
    'xInventory'
  end

  def organization_name
    'Baobab Health Trust'
  end

  def about_organization
    <<EOF
<p>Baobab Health Trust, a multi donor funded organization that works with the Ministry of Health to deploy computer systems in Hospitals, would like to procure a software that would help in the management of its fixed assets that are procured and deployed in the various hospitals.</p><p>
Once the assets are procured, they are registered and kept in a stores room. Dispatch is done upon request from the user departments. Preferably there will be two storerooms, one at the Head office and the other at the regional office in Blantyre. The system should also be able to track transfers of assets between the two store rooms.</p>
EOF

  end

  def print_content(str)                                                           
    return '' if str.blank?                                                     
    str.html_safe.gsub(/\r\n?/,"<br/>")                                         
  end

  def admin?
    unless User.current_user.blank?
      User.current_user.user_roles.map(&:role).include?('admin') 
    end
  end

end
