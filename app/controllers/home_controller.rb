class HomeController < ApplicationController
  def index
    @data = Hash.new(0)
    (Item.group(:name).where("current_quantity > 0") || []).each do |asset|
      @data[asset.name] += asset.current_quantity
    end
  end

end
