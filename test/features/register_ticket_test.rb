require 'test_helper'
require "minitest/rails/capybara"

class RegisterTicketTest < Capybara::Rails::TestCase
  setup do
    @initial_env_value = ENV['NEW_TICKETING_SYSTEM_ENABLED']

    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'true'

    @conference = create(:conference)
    create(:call_for_participation, conference: @conference )
    @admin = create(:user, person: create(:person), role: 'admin')
    @person = create(:person)
    @user = create(:user, person: @person, role: 'submitter')
    @invited = create(:invited, email: @user.person.email, conference: @conference)
    @attendance_status = create(:attendance_status, person:  @user.person, conference: @conference, status: "Invited")

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = @initial_env_value

    ActionMailer::Base.deliveries.clear
  end

  test 'invited person can register through to the ticketing form' do
    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')
      choose('Individual')

      click_on 'Get Your Ticket'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_text "Success: Your IFF Ticket has been issued!"
  end

  test 'registered person cannot register twice' do
    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

    register_ticket

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

    register_ticket

    assert_text "You cannot register to the conference twice"
  end

  test 'tickets not completed can be completed later' do
    _ticket = create(:ticket, person: @user.person, conference: @conference, status: "pending", amount: "850", ticket_option: "Organizational")

    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

    register_ticket

    assert_text "Success: Your IFF Ticket has been issued!"

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/view_ticket"

    assert_text "Amount: 0 $"
  end

  test 'ticket form has mandatory fields' do
    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

    within '#register_ticket' do

      click_on 'Get Your Ticket'
    end

    assert_text "can't be blank"
  end

  test 'only reports not filled mandatory fields' do
    login_as(@user)

    visit "/#{@conference.acronym}/invitations/#{@invited.id}/ticketing_form"

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

  test 'invited person can register ticket and cancel it after' do
    login_as(@user)

    click_on 'Claim IFF Ticket'

    register_ticket

    click_on 'View Ticket'
    click_on 'Cancel Ticket'

    assert_text "You have canceled your ticket"
  end

  test 'invited person has posibility to register another ticket after admin cancels its last' do
    login_as(@user)
    click_on 'Claim IFF Ticket'
    register_ticket
    click_on 'Logout'

    login_as(@admin)

    visit "/people/#{@person.id}?conference_acronym=#{@conference.acronym}"
    click_on 'Cancel Ticket'

    assert_text "Ticket Canceled"

    click_on 'Logout'
    login_as(@user)

    assert_text "Claim IFF Ticket"
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

  def register_ticket
    within '#register_ticket' do
      fill_in 'ticket[public_name]', with: 'test'
      select('she', from: 'ticket[gender_pronoun]')
      check('ticket[iff_before][]', option: '2015')
      check('ticket[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'ticket[interested_in_volunteer]')
      check('ticket[iff_days][]', option: 'Monday, April 1st')
      check('ticket[code_of_conduct]')
      choose('Individual')

      click_on 'Get Your Ticket'
    end
  end
end
