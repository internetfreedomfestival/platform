require 'test_helper'
require 'minitest/rails/capybara'

class DifListTest < Capybara::Rails::TestCase
  setup do
    FactoryBot.create(:call_for_participation, conference: @conference)
    @admin = create(:user, person: create(:person, public_name: nil), role: 'admin')
    @event = create(:event)
    @user = create(:user)
    @conference = @event.conference
    @other_person = create(:person)
    @dif = create(:dif, event: @event, person: @user.person, recipient_travel_stipend: @other_person.email)
  end

  test 'DIF table shows DIF requests contained in Events' do
    login_as(@admin)

    click_on 'People'
    click_on 'DIF'

    submitter_email = @user.person.email
    recipient_of_stipend = @other_person.email

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
