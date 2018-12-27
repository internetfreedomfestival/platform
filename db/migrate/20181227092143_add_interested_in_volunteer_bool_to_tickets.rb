class AddInterestedInVolunteerBoolToTickets < ActiveRecord::Migration
  def change
    add_column :tickets, :interested_in_volunteer_bool, :boolean
  end
end
