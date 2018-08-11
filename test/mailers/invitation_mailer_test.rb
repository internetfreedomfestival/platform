require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "invite" do
    person = create(:person)
    conference = create(:conference)
    email = InvitationMailer.invitation_mail(person, conference).deliver_now
    assert_not ActionMailer::Base.deliveries.empty?
    link = "#{conference.acronym}/people/#{person.id}/ticketing_form"

    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [person.email], email.to
    assert_equal "Rejoice! You've been invited to IFF", email.subject
    assert_match link, email.body.to_s
  end
end
