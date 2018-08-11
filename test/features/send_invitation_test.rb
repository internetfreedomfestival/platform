require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @conference = create :three_day_conference
    @event = create :event, conference: @conference
    @event_person = create :event_person, event: @event
    @user = create :user, person: @event_person.person
    @admin = create(:user, person: create(:person), role: 'admin')
  end

  test 'admin receives feedback when an invitation is sent' do
    visit "/"
    within '#login' do
      fill_in 'user_email', with: @admin.email
      fill_in 'user_password', with: @admin.password
      click_on 'Sign in'
    end
    visit "/#{@conference.acronym}/people"
    click_on @event_person.person.public_name

    click_on 'Send invitation'

    assert_text 'Person was invited.'
  end

  test 'admin receives feedback when an invitation is sent twice' do
    visit "/"
    within '#login' do
      fill_in 'user_email', with: @admin.email
      fill_in 'user_password', with: @admin.password
      click_on 'Sign in'
    end
    visit "/#{@conference.acronym}/people"
    click_on @event_person.person.public_name

    click_on 'Send invitation'
    click_on 'Send invitation'


    assert_text 'You have already sent an invitation to this person.'
  end
end
