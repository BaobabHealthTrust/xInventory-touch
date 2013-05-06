class SuppliersController < ApplicationController
  before_filter :check_authorized

  def show
  end

  def create
    supplier = Supplier.new()
    supplier.name = params[:supplier]['name']
    supplier.phone_number = params[:supplier]['phone_num'] unless params[:supplier]['phone_num'].blank?
    supplier.description = params[:supplier]['description'] unless params[:supplier]['description'].blank?
    supplier.address = params[:supplier]['address'] unless params[:supplier]['address'].blank?
    if supplier.save
      flash[:notice] = 'Successfully created.'
    else
      flash[:error] = 'Something went wrong - did not create.'
    end
    redirect_to '/create_new_supplier'
  end

  def search 
    @suppliers = Supplier.order('Name ASC')
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  private                                                                       
                                                                                
  def check_authorized                                                          
    if action_name == 'new' or action_name == 'create'                          
      unless admin?                                                             
        redirect_to '/suppliers'                                            
      end                                                                       
    end                                                                         
  end

end
