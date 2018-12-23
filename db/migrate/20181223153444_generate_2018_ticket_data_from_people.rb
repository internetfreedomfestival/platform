class Generate2018TicketDataFromPeople < ActiveRecord::Migration
  def up
    # ALERT!
    # This is highly dependent on the actual database values, so there is no
    # guarantee of a deterministic outcome.
    Person.find_each do |person|
      case person.old_attendance_status
      when 'confirmed'
        create_attendance_status(person, AttendanceStatus::REGISTERED)
        create_ticket(person, Ticket::COMPLETED)
      when 'waitlist'
        create_attendance_status(person, AttendanceStatus::ON_HOLD)
      when 'canceled'
        create_attendance_status(person, AttendanceStatus::INVITED)
        create_ticket(person, Ticket::CANCELED)
      when 'pending attendance'
        create_attendance_status(person, AttendanceStatus::ON_HOLD)
      end
    end
  end

  def down
    raise ActiveRecord::Rollback, 'ERROR: Cannot revert the migration'
  end

  private

  def conference
    @conference ||= Conference.find_by(acronym: 'IFF2018')
  end

  def create_attendance_status(person, status)
    Rails.logger.info "Creating attendance status '#{status}' for person id ##{person.id} on conference '#{conference.acronym}'"
    AttendanceStatus.create!(person: person, conference: conference, status: status, created_at: '2018-03-10')
  end

  def create_ticket(person, status)
    public_name = person.public_name.blank? ? person.first_name : person.public_name
    gender_pronoun = person.gender.blank? ? 'Other' : person.gender
    iff_before = person.iff_before.blank? ? ['Not yet!'] : person.iff_before.reject(&:blank?)
    iff_goals = person.iff_goals_previous.blank? ? ['Undisclosed'] : person.iff_goals_previous.lines.map(&:chomp).reject(&:blank?)
    iff_days = ['Full week']
    interested_in_volunteer = !!person.interested_in_volunteer

    Rails.logger.info "Creating ticket '#{status}' for person id ##{person.id} on conference '#{conference.acronym}'"
    Ticket.create!(person: person, conference: conference, status: status, created_at: '2018-03-10',
                  public_name: public_name, gender_pronoun: gender_pronoun, iff_before: iff_before,
                  iff_goals: iff_goals, iff_days: iff_days, interested_in_volunteer: interested_in_volunteer,
                  ticket_option: Ticket::INDIVIDUAL, code_of_conduct: 1, amount: 0)
  end
end
