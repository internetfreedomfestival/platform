require 'test_helper'
require 'minitest/rails/capybara'

class ScheduleEventTest < Capybara::Rails::TestCase
  setup do
    @conference = FactoryBot.create(:conference, email: 'info@conference.org')
    FactoryBot.create(:call_for_participation, conference: @conference)
    FactoryBot.create(:notification, conference: @conference)
    [
      'Collaborative Talk',
      'Workshop',
      'Panel Discussion',
      'Feature',
      'Feedback'
    ].each do |track|
      FactoryBot.create(:track, conference_id: @conference.id, name: track)
    end
    2.times { FactoryBot.create(:room, conference: @conference) }
    2.times { FactoryBot.create(:day, conference: @conference) }

    @common_user = create(:user, person: create(:person), role: 'submitter')
    @admin_user = create(:user, person: create(:person, public_name: nil), role: 'admin')
  end

  test 'accepted, confirmed and non-private events are shown in public schedule' do
    title = 'Detachment is not a dirty word'

    login_as(@common_user)
    create_new_proposal_with(title)
    logout()

    login_as(@admin_user)
    accept_proposal(title)
    confirm_proposal(title)
    schedule_proposal(title, Day.last, @conference.rooms.first)
    logout()

    go_to_public_schedule_of(@conference)
    assert_text title
  end

  def create_new_proposal_with(title)
    visit '/'

    click_on 'Submit a Session'

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: title
      fill_in 'event[subtitle]', with: 'Free as in freedom'
      fill_in 'event[description]', with: 'Round table about freedom'
      fill_in 'event[target_audience]', with: 'Session for students'
      fill_in 'event[desired_outcome]', with: 'Have a nice talk with students'
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Create Proposal'
    end

    assert_text 'Your proposal was successfully created.'
  end

  def login_as(user)
    visit '/'

    within '#login' do
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: user.password

      click_on 'Sign in'
    end
  end

  def logout
    click_on 'Logout'
  end

  def accept_proposal(title)
    click_on 'Events'
    click_on title
    click_on 'Accept event'

    assert_text 'Event was successfully updated'
  end

  def confirm_proposal(title)
    click_on 'Confirm event'

    assert_text 'Event was successfully updated'
  end

  def schedule_proposal(title, time, room)
    click_on 'Edit event'

    within '.edit_event' do
      select(time.start_date.strftime("%Y-%m-%d %H:%M"), from: 'event[start_time]')
      select(room.name, from: 'event[room_id]')

      click_on 'Update event'
    end
  end

  def go_to_public_schedule_of(conference)
    locale = 'en'

    visit "/#{locale}/#{conference.acronym}/public/schedule/custom"
  end
end
