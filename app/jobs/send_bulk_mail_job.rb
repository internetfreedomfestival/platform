class SendBulkMailJob
  include SuckerPunch::Job

  def perform(template, send_filter)
    persons = Person
              .joins(events: :conference)
              .where('conferences.id': template.conference.id)
    case send_filter
    when 'all_speakers_in_confirmed_events'
      persons = persons
                .where('events.state': 'confirmed')
                .where('event_people.event_role': 'speaker')

    when 'all_speakers_in_unconfirmed_events'
      persons = persons
                .where('events.state': 'unconfirmed')
                .where('event_people.event_role': 'speaker')
    when 'all_pending_attendance_people'
      persons = Person
                .where('attendance_status': 'pending attendance')
    when 'all_confirmed_attendance_people'
      persons = Person
                .where('attendance_status': 'confirmed')
    when 'pending_but_no_email'
      persons = []
      attending_people = Person
                .where('attendance_status': 'pending attendance')
      attending_people.each do |person|
        if person.user.confirm_attendance_email_sent.nil?
          persons << person
        end
      end
    when 'pepe_and_jamie'
      persons = Person
                .where(email: ['jamie.mackillop.jobs@gmail.com', 'pborras@internetfreedomfestival.org'])
    when 'just_jamie'
      persons = Person
                .where(email: 'jamie.mackillop.jobs@gmail.com')
    end

    if send_filter == 'all_speakers_in_confirmed_events' || send_filter == 'all_speakers_in_unconfirmed_events'
      persons = persons.group(:'people.id')
    end

    persons.each do |p|
      # Update user's confirm_attendance_email_sent if they have pending attendance status
      # Note: this will currently update any emails sent to this demographic
      if send_filter == 'all_pending_attendance_people' || send_filter == 'pending_but_no_email' || send_filter == 'pepe_and_jamie'
        if UserMailer.bulk_mail(p, template).deliver_now
          p.user.update(confirm_attendance_email_sent: Time.now)
          Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
        end
      else # Perform original bulk mail function for all non pending attendance people
        UserMailer.bulk_mail(p, template).deliver_now
        Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
      end
    end
  end
end
