require 'test_helper'

class TicketMailerTest < ActionMailer::TestCase
  test "sends ticket to the invited with the information" do
    invited = create(:invited)
    conference = invited.conference
    person = create(:person, email:invited.email)

    email = TicketingMailer.ticketing_mail(invited, conference).deliver_now

    first_name = Person.find_by(email: invited.email).first_name
    id = Person.find_by(email: invited.email).user_id

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "Here’s your 2019 IFF Ticket!", email.subject
    assert_match "#{first_name}", email.body.to_s
    assert_match "#{id}", email.body.to_s
  end
end
