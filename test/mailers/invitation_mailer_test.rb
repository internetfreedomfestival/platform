require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test "sends invitation mail to the invited email with the ticket links" do
    invited = create(:invited)
    create(:person, email:invited.email)

    email = InvitationMailer.invitation_mail(invited).deliver_now

    expected_link = "#{invited.conference.acronym}/invitations/#{invited.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "You are invited to the 2019 IFF!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test "send the invitation to the user who made the request for the ticket" do
    invited = create(:invited)
    create(:person, email:invited.email)

    email = InvitationMailer.accept_request_mail(invited).deliver_now

    expected_link = "#{invited.conference.acronym}/invitations/#{invited.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "Here’s your invite to the 2019 IFF!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test "sends invitation mail to non registred users" do
    invited = create(:invited)

    email = InvitationMailer.not_registered_invitation_mail(invited).deliver_now

    expected_link = "#{invited.conference.acronym}/invitations/#{invited.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "You are invited to the 2019 IFF!", email.subject
    assert_match expected_link, email.body.to_s
  end
end
