class AssetsController < ApplicationController
  before_filter :check_authorized

  def show
  end

  def new
    @categories = Category.order('name ASC').collect do |category|
      [category.name , category.id]
    end

    @manufacturers = Manufacturer.order('name ASC').collect do |manu|
      [manu.name , manu.id]
    end

    @projects = Project.order('name ASC').collect do |project|
      [project.name , project.id]
    end

    @donors = Donor.order('name ASC').collect do |donor|
      [donor.name , donor.id]
    end

    @status = StateType.order('name ASC').collect do |state|
      [state.name , state.id]
    end


  end

  def create
  end

  def new_category
  end

  def create_category
    category = Category.new()                                                         
    category.name = params[:category]['name']                                         
    category.abbreviation = params[:category]['abv'] unless params[:category]['abv'].blank?
    category.description = params[:category]['description'] unless params[:category]['description'].blank?
    if category.save                                                               
      flash[:notice] = 'Successfully created.'                                  
    else                                                                        
      flash[:error] = 'Something went wrong - did not create.'                  
    end                                                                         
    redirect_to '/create_new_category'
  end

  def new_state
  end

  def create_state
    state = StateType.new()                                                         
    state.name = params[:state]['name']                                         
    state.description = params[:state]['description'] unless params[:state]['description'].blank?
    if state.save                                                               
      flash[:notice] = 'Successfully created.'                                  
    else                                                                        
      flash[:error] = 'Something went wrong - did not create.'                  
    end                                                                         
    redirect_to '/create_new_state'
  end



  private                                                                       
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create' or 
        action_name == 'new_category' or action_name == 'create_category' or
        action_name == 'create_state' or action_name == 'new_state'
      unless admin?                                                             
        redirect_to '/assets'                                            
      end                                                                       
    end                                                                         
  end

end
