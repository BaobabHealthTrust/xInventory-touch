class UserController < ApplicationController
  def login
    if request.post?                                                            
      user = User.find_by_username params[:user]["username"]                   
      if user and user.password_matches?(params[:user]["password"])             
        session[:user_id] = user.id                                             
        redirect_to "/home"                                                         
      else                                                                      
        flash[:error] = 'That username and/or password was not valid.'          
      end                                                                       
    else                                                                        
      reset_session
    end
  end

  def logout
    reset_session
    redirect_to '/'
  end

end
