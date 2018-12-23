class SetDifStatusToRequested < ActiveRecord::Migration
  def up
    conference = Conference.find_by(acronym: 'IFF2019')
    events = Event.where(conference: conference, travel_assistance: true)

    events.each do |event|
      Rails.logger.info "Updating event: #{event.id}. Add value: Requested, to dif_status"
      event.dif_status = "Requested"
      event.save!
    end
  end

  def down
    Rails.logger.info "Nothing to do here!"
  end
end
