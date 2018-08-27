require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "sends invitation mail to the invited email with the ticket links" do
    invited = create(:invited)
    create(:person, email:invited.email)

    email = InvitationMailer.invitation_mail(invited).deliver_now
    first_name = Person.find_by(email: invited.email).first_name

    expected_link = "#{invited.conference.acronym}/invitations/#{invited.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "Rejoice! You've been invited to IFF", email.subject
    assert_match expected_link, email.body.to_s
  end
end
