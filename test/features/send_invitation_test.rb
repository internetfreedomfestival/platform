require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person), role: 'submitter')
  end

  teardown do
    ActionMailer::Base.deliveries.clear
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

  test 'users can send invitations to the conference by email' do
    create(:call_for_participation, conference: @conference)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: 'user@email.com'
      click_on 'Send'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text 'We have sent an invite to user@email.com'
  end

  test 'users has a limited number of invites' do
    create(:call_for_participation, conference: @conference)

    login_as(@user)

    number_of_invites = Invited::MAX_INVITES_PER_USER

    number_of_invites.times do |iteration|
      pending_invites = number_of_invites - iteration # starts with 0
      assert_text "You have #{pending_invites} invites remaining."

      within '#invitations-form' do
        fill_in 'email', with: "email#{iteration}@email.com"
        click_on 'Send'
      end
    end

    assert_text 'You have 0 invites remaining.'

    within '#invitations-form' do
      fill_in 'email', with: 'three@email.com'
      click_on 'Send'
    end

    assert_equal 3, ActionMailer::Base.deliveries.size
    assert_text 'You have already sent all your available invitations'
  end

  test 'users cannot invite people already invited' do
    same_email = 'user@email.com'
    create(:call_for_participation, conference: @conference)
    create(:invited, email: same_email, conference: @conference)

    login_as(@user)

    within '#invitations-form' do
      fill_in 'email', with: same_email
      click_on 'Send'
    end

    assert_equal 0, ActionMailer::Base.deliveries.size
    assert_text 'The user you are trying to invite has already received an invite'
  end

  test 'person can access to the invitation link' do
    invited = create(:invited, person: @user.person, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    assert_text 'Get your ticket'
  end

  test 'person cannot access to other conferences with same invitation' do
    other_conference = create(:conference)
    other_invited = create(:invited, person: @user.person, conference: other_conference)

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
