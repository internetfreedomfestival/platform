require 'test_helper'
require "minitest/rails/capybara"

class SendInvitationTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @admin = create(:user, person: create(:person), role: 'admin')
    @person_user = create(:user, person: create(:person), role: 'submitter')
    @person = @person_user.person
  end

  test 'person can register through to the ticketing form' do
    with_an_invited_person(@person)

    login_as(@person_user)

    visit "/#{@conference.acronym}/people/#{@person.id}/ticketing_form"

    within '#register_ticket' do
      fill_in 'person[public_name]', with: 'test'
      select('she', from: 'person[gender_pronoun]')
      check('person[iff_before][]', option: '2015')
      check('person[iff_goals][]', option: 'Requesting support with a specific issue')
      select('Yes, sounds fun!', from: 'person[interested_in_volunteer]')
      check('person[iff_days][]', option: 'Monday, April 1st')

      click_on 'Register'
    end
    assert_text "You've been succesfuly registered"
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

  def with_an_invited_person(person)
    login_as(@admin)
    go_to_conference_person_profile(@conference, @person)
    click_on 'Send invitation'
    click_on 'Logout'
  end
end
