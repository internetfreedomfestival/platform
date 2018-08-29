require 'test_helper'
require "minitest/rails/capybara"

class RegisterFormTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @user = create(:user, person: create(:person, public_name: nil), role: 'submitter')
    @cfp = create(:call_for_participation, conference: @conference)
  end

  test 'new user can complete his profile through to the sign up form' do
    visit '/'

    click_on 'Sign Up'

    within '#register_form' do
      fill_in 'user_email', with: 'sample@email.com'
      fill_in 'user_person_attributes_email_confirm', with: 'sample@email.com'
      fill_in 'user_password', with: 'password'
      fill_in 'user_password_confirmation', with: 'password'
      fill_in 'user_person_attributes_first_name', with: 'Name'
      fill_in 'user_person_attributes_last_name', with: 'Surname'
      fill_in 'user_person_attributes_pgp_key', with: '0xf60a89ad6ff97a2f'
      select 'Female', from: 'user_person_attributes_gender'
      select 'Croatia', from: 'user_person_attributes_country_of_origin'
      select 'No', from: 'user_person_attributes_group'
      check 'professional_background[]', option: 'Software/Web Development'
      fill_in 'user_person_attributes_other_background', with: 'Product Owner'
      fill_in 'user_person_attributes_organization', with: 'Devscola'
      fill_in 'user_person_attributes_project', with: 'IFF'
      choose 'Yes, keep me updated!'
      choose 'Yes, I want an invite'

      click_on 'Register'
    end

    assert_text 'An email with confirmation instructions has been sent to the address you provided'
  end

  test 'user can edit his profile through to the register form' do
    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person/edit"

    within '#register_form' do
      fill_in 'person[email]', with: 'test@test.com'
      fill_in 'person[email_confirm]', with: 'test@test.com'
      fill_in 'person[first_name]', with: 'test'
      select 'Female', from: 'person[gender]'
      select 'Albania', from: 'person[country_of_origin]'
      check 'person[professional_background][]', option: 'Software/Web Development'
      choose 'Yes, keep me updated!'
      choose 'Yes, I want an invite'

      click_on 'Update your Registration for the 2018 IFF'
    end

    assert_text "You have successfully registered for the 2018 IFF!"
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
