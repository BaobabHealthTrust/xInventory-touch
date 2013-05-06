class ManufacturerController < ApplicationController
  before_filter :check_authorized
  
  def show
  end

  def create
    manufacturer = Manufacturer.new()
    manufacturer.name = params[:manufacturer]['name']
    unless params[:manufacturer]['description'].blank?
      manufacturer.description = params[:manufacturer]['description'] 
    end

    if manufacturer.save
      flash[:notice] = 'Successfully created.'
    else
      flash[:error] = 'Something went wrong - did not create.'
    end
    redirect_to '/create_new_manufacturer'
  end

  def search 
    @manufacturers = Manufacturer.order('Name ASC')
  end

  def show
    @manufacturer = Manufacturer.find(params[:id])
  end

  private

  def check_authorized
    if action_name == 'new' or action_name == 'create'
      unless admin?
        redirect_to '/manufacturers'
      end
    end
  end

end
