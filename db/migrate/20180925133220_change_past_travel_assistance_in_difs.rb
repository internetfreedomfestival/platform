class ChangePastTravelAssistanceInDifs < ActiveRecord::Migration
  def change
    change_column :difs, :past_travel_assistance, :string
  end
end
