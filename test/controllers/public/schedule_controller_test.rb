require 'test_helper'

class Public::ScheduleControllerTest < ActionController::TestCase
  setup do
    @conference = create(:three_day_conference_with_events)
  end

  test 'redirects schedule main page to public custom path' do
    get :index, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'gets to schedule custom path' do
    get :custom, conference_acronym: @conference.acronym
    assert_response :success
  end
end
