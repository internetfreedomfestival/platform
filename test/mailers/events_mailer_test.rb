require 'test_helper'

class EventsMailerTest < ActionMailer::TestCase
  test 'sends mail to the speaker when creates new call for proposal' do
    person = create(:person)
    event = create(:event)

    email = EventsMailer.create_event_mail(person.email, event).deliver_now
    session_title = event.title

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [person.email], email.to
    assert_equal "Success! #{event.conference.alt_title} Session Submitted", email.subject
    assert_match session_title, email.body.to_s
  end

  test 'sends mail to the collaborators when speaker creates new call for proposal' do
    person = create(:person)
    event = create(:event)
    other_presenters = create(:event_person, person: person, event: event, event_role: :collaborator)

    email = EventsMailer.create_event_mail(other_presenters.person.email, event).deliver_now
    session_title = event.title

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [other_presenters.person.email], email.to
    assert_equal "Success! #{event.conference.alt_title} Session Submitted", email.subject
    assert_match session_title, email.body.to_s
  end

  test 'sends mail to the submitter when the event is accepted' do
    conference = create(:conference, title: 'IFF 2019')
    person = create(:person)
    event = create(:event, conference: conference)
    create(:event_person, event: event, person: person, event_role: :submitter)

    email = EventsMailer.accepted_event_email(event).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [event.submitter.email], email.to
    assert_equal "Congrats! You’ll be presenting at the #{conference.alt_title}", email.subject
    assert_match event.title, email.body.to_s
    assert_match event.event_type, email.body.to_s
    assert_match "time for this session is: #{event.time_slots}", email.body.to_s
  end
end
