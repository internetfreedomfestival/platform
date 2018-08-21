require 'test_helper'
require "minitest/rails/capybara"

class RegisterTicketTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person, public_name: nil), role: 'submitter')
    @attendee = create(:attendee, conference: @conference)
  end

  test 'invited person can register through to the ticketing form' do
    invited = create(:invited, person: @user.person, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')

      click_on 'Register'
    end

    assert_text "You've been succesfuly registered"
  end

  test 'registered person cannot register twice' do
    invited = create(:invited, person: @user.person, conference: @conference)
    _attendee = create(:attendee, person: invited.person, conference: invited.conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')

      click_on 'Register'
    end

    assert_text "You cannot register to the conference twice"
  end

  test 'ticket form has mandatory fields' do
    invited = create(:invited, person: @user.person, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      click_on 'Register'
    end

    assert_text "You cannot get a ticket without public name, gender pronoun, past editions, goals, attendance days"
  end

  test 'only reports not filled mandatory fields' do
    invited = create(:invited, person: @user.person, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')

      click_on 'Register'
    end

    assert_text "You cannot get a ticket without public name, goals, attendance days"
  end

  test 'admin can view users with ticket' do
    login_as(@admin)

    visit "/#{@conference.acronym}/people"

    click_on 'Attendees'

    assert_text @attendee.person.public_name
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
end
