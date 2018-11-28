require 'test_helper'
require 'minitest/rails/capybara'

class PersonProfileTest < Capybara::Rails::TestCase
  setup do
    @initial_env_value = ENV['NEW_TICKETING_SYSTEM_ENABLED']

    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = 'true'

    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @user = create(:user, person: create(:person), role: 'submitter')

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ENV['NEW_TICKETING_SYSTEM_ENABLED'] = @initial_env_value

    ActionMailer::Base.deliveries.clear
  end

  test 'number of remaining invites is visible for people with assigned invites' do
    create(:call_for_participation, conference: @conference)
    create(:invited, email: @user.person.email, person: @admin.person, conference: @conference)

    login_as(@admin)

    go_to_conference_person_profile(@conference, @user.person)

    assert_text "Invitations Remaining: #{Invited::REGULAR_INVITES_PER_USER}"
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

  def go_to_conference_person_profile(conference, person)
    visit "/#{conference.acronym}/people"

    click_on person.public_name
  end
end
