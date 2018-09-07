require 'test_helper'
require "minitest/rails/capybara"

class RegisterTicketTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person, public_name: nil), role: 'submitter')

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test 'invited person can register through to the ticketing form' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')
      check('person[code_of_conduct][]', option: 'true')

      click_on 'Register'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text "You've been succesfully registered"
  end

  test 'registered person cannot register twice' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')
      check('person[code_of_conduct][]', option: 'true')

      click_on 'Register'
    end
    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')
      check('person[code_of_conduct][]', option: 'true')

      click_on 'Register'
    end

    assert_text "You cannot register to the conference twice"
  end

  test 'ticket form has mandatory fields' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      click_on 'Register'
    end

    assert_text "You cannot get a ticket without public name, gender pronoun, past editions, goals, attendance days"
  end

  test 'only reports not filled mandatory fields' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

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
    attendee = AttendanceStatus.create(
      person: create(:person),
      conference: @conference,
      status: AttendanceStatus::REGISTERED
    )

    login_as(@admin)

    visit "/#{@conference.acronym}/people"

    click_on 'Attendees'

    assert_text attendee.person.public_name
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
