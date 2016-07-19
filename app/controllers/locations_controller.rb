class LocationsController < ApplicationController
  def index
     @page_title = "<h1>Locations <small>...</small></h1>"
     render :layout => 'imenu'
  end

  def add_location
    if request.post?
      site = Site.new()
      site.name = params[:location][:name]
      site.description = params[:location][:description]

      if site.save
        print_and_redirect("/print_barcode/#{site.id}", "/locations") and return
      end

    end
  end

  def print_location
    if request.post?
      print_and_redirect("/print_barcode/#{params[:location][:location]}", "/locations") and return
    end
    @locations = Site.order('name ASC').collect do |site|
      [site.name , site.id]
    end
  end

  def print_barcode
    print_string = Site.find(params[:id]).barcode_label
    send_data(print_string,:type=>"application/label; charset=utf-8", :stream=> false,
    :filename=>"#{params[:id]}#{rand(10000)}.lbl", :disposition => "inline")
  end

  def validate_name
    render :text => name_validator(params[:id]) and return
  end

  def name_validator(name)
    name = Site.where(:'name' => name)
    return ! name.blank? ? true : false
  end
end
