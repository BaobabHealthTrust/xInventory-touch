class DonorsController < ApplicationController
  before_filter :check_authorized

  def show
    @donor = Donor.find(params[:id])
  end

  def edit_donor_details
    @donor = Donor.find(params[:id])
    if request.post?
      @donor.name = params[:donor]['name']
      @donor.abbreviation = params[:donor]['abv'] unless params[:donor]['abv'].blank?
      @donor.description = params[:donor]['description'] unless params[:donor]['description'].blank?
      @donor.save
      redirect_to donor_details_url(:id => @donor.id)
    end
  end

  def delete
    @donor = Donor.find(params[:id])
    @donor.voided = true
    @donor.void_reason = 'Removed by user'
    @donor.save
    redirect_to '/donor_search'
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

  private                                                                       
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create'                          
      unless admin?                                                             
        redirect_to '/donors'                                            
      end                                                                       
    end                                                                         
  end

end
