class MovePublicTypeDataIntoTargetAudience < ActiveRecord::Migration
  def up
    conference = Conference.find_by(acronym: 'IFF2019')
    events = Event.where(conference: conference)

    events.each do |event|
      Rails.logger.info "Updating target_audience on event: #{event.id}. Old value: #{event.target_audience}, new value: #{event.public_type}"

      event.target_audience = event.public_type if event.target_audience.nil? || event.target_audience.empty?
      event.public_type = nil
      event.save
    end
  end

  def down
    Rails.logger.info "Nothing to do here!"
  end
end
