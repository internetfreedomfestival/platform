require 'test_helper'
require "minitest/rails/capybara"

class RegisterTicketTest < Capybara::Rails::TestCase
  setup do
    @initial_env_value = ENV['NEW_TICKETING_SYSTEM_ENABLED']

    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'true'

    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person, public_name: nil), role: 'submitter')

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = @initial_env_value

    ActionMailer::Base.deliveries.clear
  end

  test 'invited person can register through to the ticketing form' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')
      choose('Community')
      click_on 'Not This Time'

      click_on 'Get Your Ticket'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text "Success: Your IFF Ticket has been issued!"
  end

  test 'registered person cannot register twice' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"



    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')

      choose('Community')
      click_on 'Not This Time'

      click_on 'Get Your Ticket'
    end
    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')

      choose('Community')
      click_on 'Not This Time'

      click_on 'Get Your Ticket'
    end

    assert_text "You cannot register to the conference twice"
  end


  test 'tickets not completed can be completed later' do
    invited = create(:invited, email: @user.person.email, conference: @conference)
    ticket = create(:ticket, person: @user.person, conference: @conference, status: "pending", amount: "850", ticket_option: "Organizational")

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')

      choose('Community')
      click_on 'Not This Time'

      click_on 'Get Your Ticket'
    end

    assert_text "Success: Your IFF Ticket has been issued!"

    visit "/#{@conference.acronym}/invitations/#{invited.id}/view_ticket"

    assert_text "Amount: 0 $"
  end

  test 'ticket form has mandatory fields' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do

      click_on 'Get Your Ticket'
    end

    assert_text "can't be blank"
  end

  test 'only reports not filled mandatory fields' do
    invited = create(:invited, email: @user.person.email, conference: @conference)

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{invited.id}/ticketing_form"

    within '#register_ticket' do
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')

      click_on 'Get Your Ticket'
    end

    assert_text "can't be blank"
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
