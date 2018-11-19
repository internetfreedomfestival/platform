class AddTravelAssistanceToDifs < ActiveRecord::Migration
  def change
    add_column :difs, :travel_assistance, :boolean
  end
end
