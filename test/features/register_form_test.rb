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
      fill_in 'sign_up_form_email', with: 'sample@email.com'
      fill_in 'sign_up_form_email_confirmation', with: 'sample@email.com'
      fill_in 'sign_up_form_password', with: 'password'
      fill_in 'sign_up_form_password_confirmation', with: 'password'
      fill_in 'sign_up_form_first_name', with: 'Name'
      fill_in 'sign_up_form_last_name', with: 'Surname'
      fill_in 'sign_up_form_pgp_key', with: '0xf60a89ad6ff97a2f'
      select 'Female', from: 'sign_up_form_gender'
      select 'Croatia', from: 'sign_up_form_country_of_origin'
      select 'No', from: 'sign_up_form_group'
      check 'sign_up_form[professional_background][]', option: 'Software/Web Development'
      fill_in 'sign_up_form_other_background', with: 'Product Owner'
      fill_in 'sign_up_form_organization', with: 'Devscola'
      fill_in 'sign_up_form_project', with: 'IFF'
      choose 'Yes, keep me updated!'
      choose 'Yes, I want an invite'

      click_on 'Register'
    end

    assert_text 'An email with confirmation instructions has been sent to the address you provided'
  end

  test 'new user cannot complete his profile without required information' do
    visit '/'

    click_on 'Sign Up'

    within '#register_form' do
      fill_in 'sign_up_form_email', with: 'sample@email.com'
      fill_in 'sign_up_form_email_confirmation', with: 'sample@email.com'
      fill_in 'sign_up_form_password', with: 'password'
      fill_in 'sign_up_form_password_confirmation', with: 'password'
      select 'Female', from: 'sign_up_form_gender'
      select 'Croatia', from: 'sign_up_form_country_of_origin'
      check 'sign_up_form[professional_background][]', option: 'Software/Web Development'
      choose 'Yes, keep me updated!'
      choose 'Yes, I want an invite'

      click_on 'Register'
    end

    assert_text "can't be blank"
  end

  test 'user can edit his profile through to the register form' do
    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person/edit"

    within '#register_form' do
      fill_in 'person[email]', with: 'test@test.com'
      fill_in 'person[email_confirmation]', with: 'test@test.com'
      fill_in 'person[first_name]', with: 'test'
      select 'Female', from: 'person[gender]'
      select 'Albania', from: 'person[country_of_origin]'
      check 'person[professional_background][]', option: 'Software/Web Development'
      choose 'Yes, keep me updated!'
      choose 'Yes, I want an invite'

      click_on 'Update your profile'
    end

    assert_text "You have successfully updated your profile for the 2019 IFF!"
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
