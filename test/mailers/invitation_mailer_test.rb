require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test 'sends invitation mail to the invited email with the ticket links' do
    invitation = create(:invite)
    create(:person, email: invitation.email)

    email = InvitationMailer.invitation_mail(invitation).deliver_now

    expected_link = "#{invitation.conference.acronym}/invitations/#{invitation.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitation.email], email.to
    assert_equal 'You are invited to claim an IFF Ticket!', email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'send the invitation to the user who made the request for the ticket' do
    invitation = create(:invite)
    create(:person, email: invitation.email)

    email = InvitationMailer.accept_request_mail(invitation).deliver_now

    expected_link = "#{invitation.conference.acronym}/invitations/#{invitation.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitation.email], email.to
    assert_equal "Here’s your invite to the #{invitation.conference.alt_title}!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends invitation mail to non registered users' do
    invitation = create(:invite)

    email = InvitationMailer.not_registered_invitation_mail(invitation).deliver_now

    expected_link = "#{invitation.conference.acronym}/invitations/#{invitation.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitation.email], email.to
    assert_equal 'You are invited to claim an IFF Ticket!', email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends invitation mail from a regular user' do
    invitation = create(:invite)
    inviter = invitation.person

    email = InvitationMailer.additional_invitation_mail(invitation).deliver_now

    expected_link = "#{invitation.conference.acronym}/invitations/#{invitation.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitation.email], email.to
    assert_equal "#{inviter.first_name} invited you to get an IFF Ticket!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends accept request mail from a user' do
    invitation = create(:invite)
    invitee = create(:person, email: invitation.email)

    email = InvitationMailer.accept_request_mail(invitation).deliver_now

    expected_link = "#{invitation.conference.acronym}/invitations/#{invitation.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitee.email], email.to
    assert_equal "Here’s your invite to the #{invitation.conference.alt_title}!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends on hold request mail from a user' do
    person = create(:person)
    conference = create(:conference)

    email = InvitationMailer.on_hold_request_mail(person, conference).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [person.email], email.to
    assert_equal 'IFF Ticket Request On Hold', email.subject
  end
end
