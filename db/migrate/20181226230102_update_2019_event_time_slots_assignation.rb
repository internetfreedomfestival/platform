class Update2019EventTimeSlotsAssignation < ActiveRecord::Migration
  def up
    conference = Conference.find_by(acronym: 'IFF2019')
    events = Event.where(conference: conference)

    events.find_each do |event|
      time_slots = normalize_time_slots(event.time_slots)

      next if time_slots == event.time_slots

      Rails.logger.info "Updating time slots for event ##{event.id} from #{event.time_slots} to #{time_slots}"
      event.update_attribute('time_slots', time_slots)
    end
  end

  def down
    Rails.logger.info 'Nothing to do here!'
  end

  private

  def normalize_time_slots(slots)
    return 4 if slots == 3
    return 8 if slots == 6

    slots
  end
end
