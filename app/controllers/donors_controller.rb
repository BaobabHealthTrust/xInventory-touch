class DonorsController < ApplicationController
  before_filter :check_authorized

  def show
  end

  def create
    donor = Donor.new()
    donor.name = params[:donor]['name']
    donor.abbreviation = params[:donor]['abv'] unless params[:donor]['abv'].blank?
    donor.description = params[:donor]['description'] unless params[:donor]['description'].blank?
    if donor.save
      flash[:notice] = 'Successfully created.'
    else
      flash[:error] = 'Something went wrong - did not create.'
    end
    redirect_to '/create_new_donor'
  end

  def search 
    @donors = Donor.order('Name ASC')
  end

  def show
    @donor = Donor.find(params[:id])
  end

  private                                                                       
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create'                          
      unless admin?                                                             
        redirect_to '/donors'                                            
      end                                                                       
    end                                                                         
  end

end
