require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @initial_env_value = ENV['NEW_TICKETING_SYSTEM_ENABLED']

    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'true'

    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person), role: 'submitter')

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = @initial_env_value

    ActionMailer::Base.deliveries.clear
  end

  test 'admin can invite non platform users' do
    login_as(@admin)

    click_on 'Invites'

    within '#invitations-form' do
      fill_in 'email', with: 'user@email.com'
      click_on 'Send'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'We have sent an invite to user@email.com'
  end

  test '[BUG] emails from admin invites does not contain blank spaces' do
    login_as(@admin)

    click_on 'Invites'

    within '#invitations-form' do
      fill_in 'email', with: ' user@email.com '
      click_on 'Send'
    end

    invite = Invited.last

    assert_equal invite.email, 'user@email.com'
  end

  test 'admin receives feedback when an invitation is sent' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @user.person)

    click_on 'Send invitation'

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'Person was invited.'
  end

  test 'admin receives feedback when an invitation is sent twice' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @user.person)
    click_on 'Send invitation'

    click_on 'Send invitation'

    assert_equal 2, ActionMailer::Base.deliveries.size
    assert_text "This person was already invited but we've sent the invitation again."
  end

  test 'users cannot send invitations to the conference by email if ticketing system is not enabled' do
    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'false'

    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference)

    login_as(@user)

    assert_no_selector '#invitations-form'
  end

  test 'invited users can send invitations to the conference by email' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: 'user@email.com'
      click_on 'Send'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'We have sent an invite to user@email.com'
  end

  test 'users holding a ticket can send invitations to the conference by email' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::REGISTERED)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: 'user@email.com'
      click_on 'Send'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'We have sent an invite to user@email.com'
  end

  test '[BUG] emails in user invites does not contain blank spaces' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: ' user@email.com '
      click_on 'Send'
    end

    invite = Invited.last
    assert_equal invite.email, 'user@email.com'
  end

  # test 'users can request invitation to the conference' do
  #   create(:call_for_participation, conference: @conference)
  #
  #   login_as(@user)
  #
  #   within '#request_invitation' do
  #     click_on 'Request Invite'
  #   end
  #
  #   assert_equal 1, ActionMailer::Base.deliveries.size
  #   assert_text 'Your ticket request has been received.'
  # end

  # test 'users cannot request invitation to the conference if ticketing system is not enabled' do
  #   ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'false'
  #
  #   create(:call_for_participation, conference: @conference)
  #
  #   login_as(@user)
  #
  #   assert_no_selector '#request_invitation'
  # end

  # test 'admin can accept a request invitation' do
  #   create(:call_for_participation, conference: @conference)
  #
  #   login_as(@user)
  #
  #   within '#request_invitation' do
  #     click_on 'Request Invite'
  #   end
  #
  #   click_on 'Logout'
  #
  #   login_as(@admin)
  #
  #   go_to_conference_person_profile(@conference, @user.person)
  #
  #   click_on 'Accept request'
  #
  #   assert_text 'Person was invited.'
  # end

  # test 'users invited by admin that they send a request invitation not have a extra invitations' do
  #   create(:call_for_participation, conference: @conference)
  #
  #   login_as(@user)
  #
  #   within '#request_invitation' do
  #     click_on 'Request Invite'
  #   end
  #
  #   click_on 'Logout'
  #
  #   login_as(@admin)
  #
  #   go_to_conference_person_profile(@conference, @user.person)
  #
  #   click_on 'Accept request'
  #
  #   click_on 'Logout'
  #
  #   login_as(@user)
  #
  #   assert_no_text 'invites remaining.'
  # end

  test 'invited users have a limited number of invites' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)

    login_as(@user)

    number_of_invites = Invited::REGULAR_INVITES_PER_USER

    number_of_invites.times do |iteration|
      pending_invites = number_of_invites - iteration # starts with 0
      assert_text "You have #{pending_invites} invites remaining."

      within '#invitations-form' do
        fill_in 'email', with: "email#{iteration}@email.com"
        click_on 'Send'
      end
    end

    assert_text 'invites remaining.'
  end

  test 'users holding a ticket have a limited number of invites' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::REGISTERED)

    login_as(@user)

    number_of_invites = Invited::REGULAR_INVITES_PER_USER

    number_of_invites.times do |iteration|
      pending_invites = number_of_invites - iteration # starts with 0
      assert_text "You have #{pending_invites} invites remaining."

      within '#invitations-form' do
        fill_in 'email', with: "email#{iteration}@email.com"
        click_on 'Send'
      end
    end

    assert_text 'invites remaining.'
  end

  test 'invited users can be granted a specific number of invites' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)

    number_of_invites = 100
    InvitesAssignation.create(person: @user.person, conference: @conference, number: number_of_invites)

    login_as(@user)

    assert_text "You have #{number_of_invites} invites remaining."
  end

  test 'users holding a ticket can be granted a specific number of invites' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::REGISTERED)

    number_of_invites = 100
    InvitesAssignation.create(person: @user.person, conference: @conference, number: number_of_invites)

    login_as(@user)

    assert_text "You have #{number_of_invites} invites remaining."
  end

  test 'invited users can be granted packages of 5 additional invitations' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)

    login_as(@admin)

    go_to_conference_person_profile(@conference, @user.person)
    click_on 'Assign +5 invitations'
    click_on 'Logout'

    login_as(@user)

    assert_text 'You have 10 invites remaining.'
  end

  test 'users holding a ticket can be granted packages of 5 additional invitations' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::REGISTERED)

    login_as(@admin)

    go_to_conference_person_profile(@conference, @user.person)
    click_on 'Assign +5 invitations'
    click_on 'Logout'

    login_as(@user)

    assert_text 'You have 10 invites remaining.'
  end

  test 'uninvited users cannot be granted packages of 5 additional invitations' do
    create(:call_for_participation, conference: @conference)

    login_as(@admin)

    go_to_conference_person_profile(@conference, @user.person)

    assert_no_text 'Assign +5 invitations'
  end

  test 'users available invites can be less than zero' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference)

    number_of_invites = -100
    InvitesAssignation.create(person: @user.person, conference: @conference, number: number_of_invites)

    login_as(@user)

    assert_text 'invites remaining.'
  end

  test 'users cannot invite people already invited' do
    same_email = 'user@email.com'
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference, sharing_allowed: true)
    create(:attendance_status, person: @user.person, conference: @conference, status: AttendanceStatus::INVITED)
    create(:invited, email: same_email, conference: @conference)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: same_email
      click_on 'Send'
    end

    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_text 'The user you are trying to invite has already received an invite'
  end

  # test 'users that requested invitation can not invite other people' do
  #   create(:call_for_participation, conference: @conference)
  #
  #   login_as(@user)
  #
  #   within '#request_invitation' do
  #     click_on 'Request Invite'
  #   end
  #
  #   assert_text 'Your ticket request has been received.'
  #   click_on 'Logout'
  #
  #   login_as(@admin)
  #   go_to_conference_person_profile(@conference, @user.person)
  #   click_on 'Accept request'
  #   click_on 'Logout'
  #
  #   login_as(@user)
  #   assert_no_text 'invites remaining.'
  # end

  test 'users invited by admin can invite other people' do
    create(:call_for_participation, conference: @conference)

    login_as(@admin)
    go_to_conference_person_profile(@conference, @user.person)
    click_on 'Send invitation'
    click_on 'Logout'

    login_as(@user)
    assert_text 'You have 5 invites remaining.'
  end

  test 'person can access to the invitation link' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    assert_text '2019 IFF Ticket'
  end

  test 'person cannot access to other conferences with same invitation' do
    other_conference = create(:conference)
    other_invited = create(:invited, email: @user.person.email, conference: other_conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{other_invited.id}/ticketing_form"

    assert_text 'You cannot register to the conference without an invitation'
  end

  test 'not logged person cannot access get ticket form' do
    invited = create(:invited, conference: @conference)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    assert_text 'Please register to be able to'
  end

  test 'other persons cannot access to other invitation links' do
    invited = create(:invited, person: @user.person, conference: @conference)
    @non_invited_person = create(:user, role: 'submitter')

    login_as(@non_invited_person)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    assert_text 'You cannot register to the conference without a valid invitation'
  end

  test 'invitation must exists' do
    wrong_invited_id = '123'

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{wrong_invited_id}/ticketing_form"

    assert_text 'You cannot register to the conference without a valid invitation'
  end

  private

  def login_as(user)
    visit '/'

    within '#login' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password

      click_on 'Sign in'
    end
  end

  def go_to_conference_person_profile(conference, person)
    visit "/#{conference.acronym}/people"

    click_on person.public_name
  end

  def with_an_invited_person(person)
    login_as(@admin)
    go_to_conference_person_profile(@conference, @user.person)
    click_on 'Send invitation'
    click_on 'Logout'
  end
end
