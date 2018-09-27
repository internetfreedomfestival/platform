class AddTravelSupportToEvents < ActiveRecord::Migration
  def change
    add_column :events, :travel_support, :string
  end
end
