require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @person_user = create(:user, person: create(:person), role: 'submitter')
    @person = @person_user.person
  end

  test 'admin receives feedback when an invitation is sent' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)

    click_on 'Send invitation'

    assert_text 'Person was invited.'
  end

  test 'admin receives feedback when an invitation is sent twice' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)
    click_on 'Send invitation'

    click_on 'Send invitation'

    assert_text "This person was already invited but we've sent the invitation again."
  end

  test 'person can access to the invitation link' do
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    assert_text 'Get your ticket'
  end

  test 'person cannot access without the invitation link' do
    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    assert_text 'You cannot register to the conference without an invitation'
  end

  test 'not logged person cannot access get ticket form' do
    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    assert_text 'Please register to be able to'
  end

  test 'other persons cannot access to other invitation links' do
    with_an_invited_person(@person)
    @other_person_user = create(:user, role: 'submitter')

    login_as(@other_person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

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
    go_to_conference_person_profile(@conference, @person)
    click_on 'Send invitation'
    click_on 'Logout'
  end
end
