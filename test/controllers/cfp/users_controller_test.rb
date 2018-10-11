require 'test_helper'

class Cfp::UsersControllerTest < ActionController::TestCase
  setup do
    call_for_participation = create(:call_for_participation)
    @conference = call_for_participation.conference
  end

  test 'shows registration form' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'allows registration of new user' do
    assert_difference 'User.count' do
      sign_up_form_params = {
        email: 'new_user@example.com',
        email_confirmation: 'new_user@example.com',
        password: 'frab1234',
        password_confirmation: 'frab1234',
        first_name: 'Aretha',
        gender: 'Female',
        country_of_origin: 'United States',
        professional_background: ['Software/web developer'],
        include_in_mailings: true,
        invitation_to_mattermost: true
      }
      post :create, conference_acronym: @conference.acronym, sign_up_form: sign_up_form_params
    end
    assert_response :redirect

    user = User.find_by(email: 'new_user@example.com')
    assert_not_nil user
    assert_not_nil user.confirmation_token
  end

  test 'denies the registration of users with same email' do
    sign_up_form_params = {
      email: 'new_user@example.com',
      email_confirmation: 'new_user@example.com',
      password: 'frab1234',
      password_confirmation: 'frab1234',
      first_name: 'Aretha',
      gender: 'Female',
      country_of_origin: 'United States',
      professional_background: ['Software/web developer'],
      include_in_mailings: true,
      invitation_to_mattermost: true
    }
    post :create, conference_acronym: @conference.acronym, sign_up_form: sign_up_form_params

    assert_response :redirect

    items_found = User.find_by(email: 'new_user@example.com')

    duplicated_params = sign_up_form_params
    post :create, conference_acronym: @conference.acronym, sign_up_form: duplicated_params

    items_found_after_duplicated_insertion = User.find_by(email: 'new_user@example.com')

    assert_equal items_found, items_found_after_duplicated_insertion
  end


  test 'shows password editing form' do
    login_as(:submitter)
    get :edit, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'allows editing of password' do
    user = login_as(:submitter)
    digest_before = user.password_digest
    put :update, conference_acronym: @conference.acronym, user: { password: '123frab', password_confirmation: '123frab' }
    assert_response :redirect
    user.reload
    assert_not_equal digest_before, user.password_digest
  end

  test '[:bug] redirect to action edit when validations fail' do
    login_as(:submitter)
    put :update, conference_acronym: @conference.acronym, user: { password: '123frab', password_confirmation: '123frab', email: "" }
    assert_response :success
  end
end
