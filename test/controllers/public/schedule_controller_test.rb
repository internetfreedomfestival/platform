require 'test_helper'

class Public::ScheduleControllerTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events)
  end

  test 'redirects schedule main page to public custom path' do
    get :index, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'redirects schedule for a day to public custom path' do
    get :day, day: 1, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'redirects an event to public custom path' do
    get :events, id: 1, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'redirects events list to public custom path' do
    get :events, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'displays speakers list' do
    get :speakers, conference_acronym: @conference.acronym
    assert_response :success
    get :speakers, conference_acronym: @conference.acronym, format: :xls
    assert_response :success
  end

  test 'display a speaker' do
    get :speakers, id: 1, conference_acronym: @conference.acronym
    assert_response :success
  end
end
