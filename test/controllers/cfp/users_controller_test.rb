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
        password: 'frab123',
        password_confirmation: 'frab123',
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
end
