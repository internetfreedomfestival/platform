require 'test_helper'

class TicketMailerTest < ActionMailer::TestCase
  test "sends ticket to the invited with the information" do
    ticket = create(:ticket)
    person = create(:person)
    conference = create(:conference)

    email = TicketingMailer.ticketing_mail(ticket, person, conference).deliver_now

    first_name = person.first_name
    id = person.user_id

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [person.email], email.to
    assert_equal "Here’s your #{conference.alt_title} Ticket!", email.subject
    assert_match "#{first_name}", email.body.to_s
    assert_match "#{id}", email.body.to_s
  end
end
