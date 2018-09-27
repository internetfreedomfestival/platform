class AddRecipientTravelStipendToEvents < ActiveRecord::Migration
  def change
    add_column :events, :recipient_travel_stipend, :string
  end
end
