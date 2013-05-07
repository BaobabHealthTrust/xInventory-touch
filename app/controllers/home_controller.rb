class HomeController < ApplicationController
  def index
    @total_registered_assets = Item.count
    @total_available_assets = 0 
    @total_missing_assets = 0
  end
end
