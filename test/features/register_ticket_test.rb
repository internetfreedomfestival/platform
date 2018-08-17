require 'test_helper'
require "minitest/rails/capybara"

class RegisterTicketTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @person_user = create(:user, person: create(:person, public_name: nil), role: 'submitter')
    @person = @person_user.person
    @attendee = create(:attendee, conference: @conference)
  end

  test 'person can register through to the ticketing form' do
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

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

  test 'person cannot register twice' do
    with_an_registered_person(@person)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

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
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    within '#register_ticket' do
      click_on 'Register'
    end

    assert_text "You cannot get a ticket without public name, gender pronoun, past editions, goals, attendance days"
  end

  test 'only reports not filled mandatory fields' do
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

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

  def go_to_conference_person_profile(conference, person)
    visit "/#{conference.acronym}/people"

    click_on person.email
  end

  def with_an_invited_person(person)
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)
    click_on 'Send invitation'
    click_on 'Logout'
  end

  def with_an_registered_person(person)
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')

      click_on 'Register'
    end
  end
end
