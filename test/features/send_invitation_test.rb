require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @conference = create :three_day_conference
    @admin = create(:user, person: create(:person), role: 'admin')
    @person = create(:person)
  end

  test 'admin receives feedback when an invitation is sent' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)

    click_on 'Send invitation'

    assert_text 'Person was invited.'
  end

  test 'admin receives feedback when an invitation is sent twice' do
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)
    click_on 'Send invitation'

    click_on 'Send invitation'

    assert_text "This person was already invited but we've sent the invitation again."
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
