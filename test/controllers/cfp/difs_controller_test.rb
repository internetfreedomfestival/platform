require 'test_helper'

class Cfp::DifsControllerTest < ActionController::TestCase
  setup do
    @event = create(:event)
    @user = create(:user)
    @conference = @event.conference
    @dif = create(:dif, event: @event, person: @user.person)
    login_as(:admin)
  end

  test 'admin should grantee a dif' do
    get :grant, id: @dif.id, conference_acronym: @conference.acronym

    @dif.reload

    assert_equal @dif.status, "Granted"
    assert_redirected_to person_path(@dif.person)
  end
end
