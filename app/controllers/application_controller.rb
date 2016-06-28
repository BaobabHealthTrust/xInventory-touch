class ApplicationController < ActionController::Base
  protect_from_forgery                                                          
                                                                                
  before_filter :perform_basic_auth, :except => ['login','logout']                         

  def admin?                                                                    
    User.current_user.user_roles.map(&:role).include?('admin')                  
  end

  def superuser?
    User.current_user.user_roles.map(&:role).include?('superuser')
  end

  helper_method :admin?

  helper_method :superuser?

  def print_and_redirect(print_url, redirect_url, message = "Printing, please wait...")
    @print_url = print_url                                                      
    @redirect_url = redirect_url                                                
    @message = message                                                          
    render :template => 'print/print', :layout => nil                           
  end

  def current_location

		if session[:site]
			@current_location ||= Site.find(session[:site]) rescue nil

			if @current_location.nil?
				session = nil
				return
			else
				Site.current_location_id = @current_location.id
			end
		end
	end

  protected                                                                     
                                                                                
  def perform_basic_auth                                                        
    if session[:user_id].blank?                                                 
      respond_to do |format|                                                    
        format.html { redirect_to :controller => 'user',:action => 'logout' }   
      end                                                                       
    elsif not session[:user_id].blank?                                          
      User.current_user = User.where(:'id' => session[:user_id]).first        
    end                                                                         
  end 

end
