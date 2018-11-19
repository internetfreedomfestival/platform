class AddRecipientTravelStipendToDifs < ActiveRecord::Migration
  def change
    add_column :difs, :recipient_travel_stipend, :string
  end
end
