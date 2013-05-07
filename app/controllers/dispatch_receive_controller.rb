class DispatchReceiveController < ApplicationController
  before_filter :check_authorized

  def index
  end

  private                                                                       
                                                                                
  def check_authorized                                                          
    unless admin?                                                             
      redirect_to '/home'                                                   
    end                                                                       
  end

end
