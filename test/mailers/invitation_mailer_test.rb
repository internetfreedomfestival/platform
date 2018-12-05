require 'test_helper'

class InvitationMailerTest < ActionMailer::TestCase
  test 'sends invitation mail to the invited email with the ticket links' do
    invitee = create(:invited)
    create(:person, email: invitee.email)

    email = InvitationMailer.invitation_mail(invitee).deliver_now

    expected_link = "#{invitee.conference.acronym}/invitations/#{invitee.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitee.email], email.to
    assert_equal 'You are invited to claim an IFF Ticket!', email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'send the invitation to the user who made the request for the ticket' do
    invitee = create(:invited)
    create(:person, email: invitee.email)

    email = InvitationMailer.accept_request_mail(invitee).deliver_now

    expected_link = "#{invitee.conference.acronym}/invitations/#{invitee.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitee.email], email.to
    assert_equal 'Here’s your invite to the 2019 IFF!', email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends invitation mail to non registered users' do
    invitee = create(:invited)

    email = InvitationMailer.not_registered_invitation_mail(invitee).deliver_now

    expected_link = "#{invitee.conference.acronym}/invitations/#{invitee.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitee.email], email.to
    assert_equal 'You are invited to claim an IFF Ticket!', email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends invitation mail from a regular user' do
    invitee = create(:invited)
    inviter = invitee.person

    email = InvitationMailer.additional_invitation_mail(invitee).deliver_now

    expected_link = "#{invitee.conference.acronym}/invitations/#{invitee.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invitee.email], email.to
    assert_equal "#{inviter.first_name} invited you to get an IFF Ticket!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends accept request mail from a user' do
    invite = create(:invited)
    invited = create(:person, email: invite.email)

    email = InvitationMailer.accept_request_mail(invite).deliver_now

    expected_link = "#{invite.conference.acronym}/invitations/#{invite.id}/ticketing_form"
    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [invited.email], email.to
    assert_equal "Here’s your invite to the 2019 IFF!", email.subject
    assert_match expected_link, email.body.to_s
  end

  test 'sends on hold request mail from a user' do
    person = create(:person)

    email = InvitationMailer.on_hold_request_mail(person).deliver_now

    assert_not ActionMailer::Base.deliveries.empty?
    assert_equal [ENV.fetch('FROM_EMAIL')], email.from
    assert_equal [person.email], email.to
    assert_equal "IFF Ticket Request On Hold", email.subject
  end
end
