require 'test_helper'

class EventsMailerTest < ActionMailer::TestCase
  test "sends mail to the speaker when creates new call for proposal" do
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
  test "sends mail to the collaborators when speaker creates new call for proposal" do
    person = create(:person)
    event = create(:event)
    other_presenters = create(:event_person, person: person, event: event, event_role: "collaborator")

    email = EventsMailer.create_event_mail(other_presenters.person.email, event).deliver_now
    session_title = event.title

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [other_presenters.person.email], email.to
    assert_equal "Success! #{event.conference.alt_title} Session Submitted", email.subject
    assert_match session_title, email.body.to_s
  end
end
