class DispatchState < ActiveRecord::Base
  self.table_name = 'dispatch_state'
  self.default_scope -> { where "voided = 0"  }

  # attr_accessible :title, :body

  def self.create_state(asset, state, date)
    type = DispatchStateTypes.find_by_name(state).id
    previous_state = self.state(asset)
    unless previous_state.blank?
      previous_state.end_date = date
      previous_state.save
    end

    current_state = DispatchState.new()
    current_state.start_date = date
    current_state.item_id = asset
    current_state.current_state = type
    current_state.save

  end

  def self.state(item)
    state = DispatchState.where("item_id = ? AND end_date IS NULL", item).order(id: :desc).limit(1).first rescue []
  end

  def self.state_name(state)
    DispatchStateTypes.find(state.current_state).name rescue []
  end
end
