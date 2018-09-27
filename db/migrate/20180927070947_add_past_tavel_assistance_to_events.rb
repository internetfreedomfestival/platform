class AddPastTavelAssistanceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :past_travel_assistance, :string
  end
end
