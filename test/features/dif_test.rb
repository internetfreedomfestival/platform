require 'test_helper'
require 'minitest/rails/capybara'

class DifTest < Capybara::Rails::TestCase
  setup do
    @conference = FactoryBot.create(:conference)
    FactoryBot.create(:call_for_participation, conference: @conference)
    @person = FactoryBot.create(:person)
    @user = FactoryBot.create(:user, role: 'submitter', person: @person)
    @other_speaker = FactoryBot.create(:user, role: 'submitter')
    @admin = FactoryBot.create(:user, role: 'admin')
    @event = FactoryBot.create(:event, conference: @conference, travel_assistance: true, )
    FactoryBot.create(:event_person, person: @person, event: @event, event_role: 'submitter')
    FactoryBot.create(:event_person, person: @person, event: @event, event_role: 'speaker')
    FactoryBot.create(:event_person, person: @other_speaker.person, event: @event, event_role: 'speaker')
  end

  test 'DIF table shows DIF requests contained in Events' do
    login_as(@admin)

    click_on 'People'
    click_on 'DIF'

    assert_text @person.email
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
