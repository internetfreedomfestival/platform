class UpdateInterestedInVolunteerBoolInTickets < ActiveRecord::Migration
  def up
    Ticket.find_each do |ticket|
      interested_in_volunteer_bool = ['true', 't'].include?(ticket.interested_in_volunteer)
      ticket.update_attribute('interested_in_volunteer_bool', interested_in_volunteer_bool)
    end
  end

  def down
    Rails.logger.info 'Nothing to do here!'
  end
end
