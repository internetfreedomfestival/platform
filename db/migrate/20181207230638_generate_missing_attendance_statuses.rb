class GenerateMissingAttendanceStatuses < ActiveRecord::Migration
  def up
    # ALERT!
    # This is highly dependent on the actual database values, so there is no
    # guarantee of a deterministic outcome.
    conference = Conference.find_by(acronym: 'IFF2019')

    invitees = Invite.where(conference: conference).map { |invite| Person.find_by(email: invite.email.downcase) }.uniq
    attendees = AttendanceStatus.where(conference: conference).map(&:person).uniq

    missing_attendees = (invitees - attendees).compact

    missing_attendees.each do |attendee|
      Rails.logger.info "Creating attendance status '#{AttendanceStatus::INVITED}' for person id ##{attendee.id} on conference '#{conference.acronym}'"
      AttendanceStatus.create!(person: attendee, conference: conference, status: AttendanceStatus::INVITED)
    end
  end

  def down
    Rails.logger.info 'Nothing to do here!'
  end
end
