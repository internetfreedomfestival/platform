require 'test_helper'

class PeopleControllerTest < ActionController::TestCase
  setup do
    @user = create(:user)
    @person = @user.person
    @conference = create(:conference)

    @admin = login_as(:admin)
  end

  def person_params
    @person.attributes.except(*%w(id avatar_content_type avatar_file_size avatar_updated_at avatar_file_name created_at updated_at user_id))
  end

  test 'should get index' do
    get :index, conference_acronym: @conference.acronym
    assert_response :redirect
  end

  test 'should get new' do
    get :new, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should create person' do
    @person.email = generate(:email)

    assert_difference('Person.count') do
      post :create, person: person_params, conference_acronym: @conference.acronym
    end

    assert_redirected_to person_path(assigns(:person))
  end

  test 'should show person' do
    get :show, id: @person.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should get edit' do
    get :edit, id: @person.to_param, conference_acronym: @conference.acronym
    assert_response :success
  end

  test 'should update person' do
    put :update, id: @person.to_param, person: person_params, conference_acronym: @conference.acronym
    assert_redirected_to person_path(assigns(:person))
  end

  test 'should destroy person' do
    assert_difference('Person.count', -1) do
      delete :destroy, id: @person.to_param, conference_acronym: @conference.acronym
    end

    assert_redirected_to(all_people_path)
  end

  test 'should invite persons to a conference' do
    post :send_invitation, id: @person.to_param, conference_acronym: @conference.acronym

    assert_equal(@person.email, Invite.first.email)
    assert_equal(@conference, Invite.first.conference)
  end

  test 'admin can override invitation by send invitation' do
    invited_person = create(:person)
    invite = create(:invite, person: @person, conference: @conference, email: invited_person.email)

    post :send_invitation, id: invited_person.to_param, conference_acronym: @conference.acronym

    invite.reload
    assert_equal(invite.person, @admin.person)
  end

  test 'should allow person to submit event out of place' do
    post :allow_late_submissions, format: @person.to_param, conference_acronym: @conference.acronym

    @person.reload

    assert_equal(@person.late_event_submit, true)
  end

  test 'should accept invitations request' do
    post :accept_request, id: @person.to_param, conference_acronym: @conference.acronym

    assert_equal(@person.email, Invite.first.email)
    assert_equal(@conference, Invite.first.conference)
  end

  test 'should puts on hold the request' do
    post :on_hold_request, id: @person.to_param, conference_acronym: @conference.acronym

    status = AttendanceStatus.find_by(person: @person, conference: @conference)

    assert_equal(status.status, "On Hold")
  end

  test 'should reject the request' do
    post :reject, id: @person.to_param, conference_acronym: @conference.acronym

    status = AttendanceStatus.find_by(person: @person, conference: @conference)

    assert_equal(status.status, "Rejected")
  end

  test 'should remove the user invitation when the request is rejected' do
    invited_person = create(:person)
    invite = create(:invite, person: @person, conference: @conference, email: invited_person.email)

    post :reject, id: invited_person.to_param, conference_acronym: @conference.acronym

    invite = Invite.find_by(email: invited_person.email.downcase, conference: @conference)

    assert_nil(invite)
  end

  test 'should add 5 more invitations to an invited person' do
    post :send_invitation, id: @person.to_param, conference_acronym: @conference.acronym

    assert_difference 'Invite.pending_invites_for(@person, @conference)', +5 do
      post :add_invitations, id: @person.to_param, conference_acronym: @conference.acronym
    end
  end

  test 'should not add 5 more invitations to an uninvited person' do
    assert_no_difference 'Invite.pending_invites_for(@person, @conference)' do
      post :add_invitations, id: @person.to_param, conference_acronym: @conference.acronym
    end
  end
end
