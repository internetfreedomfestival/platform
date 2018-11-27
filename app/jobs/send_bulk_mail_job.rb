class SendBulkMailJob
  include SuckerPunch::Job

  def perform(template, send_filter)
    conference = template.conference
    people = Person
              .joins(events: :conference)
              .where('conferences.id': conference.id)
    case send_filter
    when 'all'
      people = Person.all
    when 'all_users_holding_ticket'
      people = Person.with_ticket(conference)
    when 'all_confirmed_dif_users'
      people = (
        Person.with_dif_granted(conference) + Person.with_dif_travel_stipend_granted(conference)
      ).uniq { |person| person.id }
    when 'all_dif_users_excluding_confirmed'
      people = (
        Person.with_dif_requested(conference) + Person.with_dif_travel_stipend_requested(conference)
      ).uniq { |person| person.id }
    when 'all_confirmed_events_presenters'
      people = Person.joins(events: :conference)
              .where('conferences.id': conference.id)
              .where(events: {state: "confirmed"} ).uniq
    when 'all_rejected_events_presenters'
      people = Person.joins(events: :conference)
              .where('conferences.id': conference.id)
              .where(events: {state: "rejected"} ).uniq

    when 'all_speakers_in_confirmed_events'
      people = people
                .where('events.state': 'confirmed')
                .where('event_people.event_role': 'speaker')

    when 'all_speakers_in_unconfirmed_events'
      people = people
                .where('events.state': 'unconfirmed')
                .where('event_people.event_role': 'speaker')
    when 'all_pending_attendance_people'
      people = Person
                .where('old_attendance_status': 'pending attendance')
    when 'all_confirmed_attendance_people'
      people = Person
                .where('old_attendance_status': 'confirmed')
    when 'pending_but_no_email'
      people = []
      attending_people = Person
                .where('old_attendance_status': 'pending attendance')
      attending_people.each do |person|
        if person.user.confirm_attendance_email_sent.nil?
          people << person
        end
      end
    when 'pepe_and_jamie'
      people = Person
                .where(email: ['jamie.mackillop.jobs@gmail.com', 'pborras@internetfreedomfestival.org'])
    when 'just_jamie'
      people = Person.where(email: 'jamie.mackillop.jobs@gmail.com')
    when 'just_test_user'
      people = Person.where(email: 'test@example.org')
    end

    if send_filter == 'all_speakers_in_confirmed_events' || send_filter == 'all_speakers_in_unconfirmed_events'
      people = people.group(:'people.id')
    end

    people.each do |p|
      # Update user's confirm_attendance_email_sent if they have pending attendance status
      # Note: this will currently update any emails sent to this demographic
      if send_filter == 'all_pending_attendance_people' || send_filter == 'pending_but_no_email' || send_filter == 'pepe_and_jamie'
        if UserMailer.bulk_mail(p, template).deliver_now
          p.user.update(confirm_attendance_email_sent: Time.now)
          Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
        end
      #elsif updates email timestamp for confirmed people only
      elsif send_filter == 'all_confirmed_attendance_people'
        if UserMailer.bulk_mail(p, template).deliver_now
          p.user.update(email_sent_to_confirmed_only: Time.now)
          Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
        end
      else # Perform original bulk mail function for all non pending attendance people
        UserMailer.bulk_mail(p, template).deliver_now
        Rails.logger.info "Mail template #{template.name} delivered to #{p.first_name} #{p.last_name} (#{p.email})"
      end
    end
  end
end
