require 'test_helper'
require 'minitest/rails/capybara'

class DifListTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    create(:call_for_participation, conference: @conference)
    @person = create(:person)
    @user = create(:user, role: 'submitter', person: @person)
    @other_speaker = create(:user, role: 'submitter')
    @admin = create(:user, role: 'admin')
    @event = create(:event, conference: @conference, travel_assistance: true, recipient_travel_stipend: @other_speaker.person.email)
    create(:event_person, person: @person, event: @event, event_role: 'submitter')
    create(:event_person, person: @person, event: @event, event_role: 'speaker')
    create(:event_person, person: @other_speaker.person, event: @event, event_role: 'speaker')
  end

  test 'DIF table shows DIF requests contained in Events' do
    login_as(@admin)

    click_on 'People'
    click_on 'DIF'

    submitter_email = @person.email
    recipient_of_stipend = @other_speaker.person.email

    assert_text submitter_email
    assert_text recipient_of_stipend
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
