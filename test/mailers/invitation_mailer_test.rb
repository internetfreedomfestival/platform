require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "invite" do
    invited = create(:invited)

    email = InvitationMailer.invitation_mail(invited).deliver_now

    expected_link = "#{invited.conference.acronym}/invitations/#{invited.person.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.person.email], email.to
    assert_equal "Rejoice! You've been invited to IFF", email.subject
    assert_match expected_link, email.body.to_s
  end
end
