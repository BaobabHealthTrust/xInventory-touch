class ManufacturerController < ApplicationController
  before_filter :check_authorized

  def index
    @page_title = "<h1>Manufacturers <small>....</small></h1>"
    render :layout => 'imenu'
  end
    
  def show
    @manufacturer = Manufacturer.find(params[:id])
  end

  def edit
    @manufacturer = Manufacturer.find(params[:id])
    if request.post?
      @manufacturer.name = params[:manufacturer]['name']
      unless params[:manufacturer]['description'].blank?
        @manufacturer.description = params[:manufacturer]['description'] 
      end
      @manufacturer.save
      redirect_to manufacturer_details_url(:id => @manufacturer.id)
    end
  end

  def delete
    @manufacturer = Manufacturer.find(params[:id])
    @manufacturer.voided = true
    @manufacturer.void_reason = 'Removed by user'
    @manufacturer.save
    redirect_to '/manufacturers_search'
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

  private

  def check_authorized
    if action_name == 'new' or action_name == 'create'
      unless admin?
        redirect_to '/manufacturers'
      end
    end
  end

end
