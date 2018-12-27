class ConsolidateInterestedInVolunteerColumnsInTickets < ActiveRecord::Migration
  def up
    change_table(:tickets) do |t|
      t.remove :interested_in_volunteer
      t.rename :interested_in_volunteer_bool, :interested_in_volunteer
    end
  end

  def down
    change_table(:tickets) do |t|
      t.rename :interested_in_volunteer, :interested_in_volunteer_bool
      t.string :interested_in_volunteer
    end

    Ticket.find_each do |ticket|
      interested_in_volunteer = ticket.interested_in_volunteer_bool? ? 'true' : 'false'
      ticket.update_attribute('interested_in_volunteer', interested_in_volunteer)
    end
  end
end
