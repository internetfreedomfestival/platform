require 'test_helper'
require 'minitest/rails/capybara'

class CfpFormTest < Capybara::Rails::TestCase
  setup do
    @conference = create(:conference)
    @event = create(:event)
    @user = create(:user, person: create(:person, public_name: nil), role: 'submitter')
    @admin_user = create(:user, person: create(:person, public_name: nil), role: 'admin')
    @cfp = create(:call_for_participation, conference: @conference)
    @person = create(:person)

    tracks = ["Collaborative Talk", "Workshop", "Panel Discussion", "Feature", "Feedback"]
    tracks.each do |track|
      Track.create!(conference: @conference, name: track)
    end

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test 'CFP form link is enabled by FeatureToggle' do
    ENV['NEW_CFP_ENABLED'] = 'false'

    login_as(@user)

    visit "/#{@conference.acronym}/cfp"

    assert_no_text 'Submit a Session for the 2019 IFF'

    ENV['NEW_CFP_ENABLED'] = 'true'

    visit "/#{@conference.acronym}/cfp"

    assert_text 'Submit a Session for the 2019 IFF'
  end

  test 'new user can create a new call for proposals' do
    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/new"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Create Proposal'
    end

    assert_text 'Your proposal was successfully created.'
  end

  test 'call for proposals needs required fields fullfilled' do
    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/new"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Create Proposal'
    end

    assert_text "can't be blank"
  end

  test 'an user cannot create two call for proposals with the same title' do
    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/new"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Create Proposal'
    end

    assert_text 'Your proposal was successfully created.'

    visit "/#{@conference.acronym}/cfp/events/new"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Create Proposal'
    end

    assert_text 'There is already a session submitted with this title.'
  end

  test 'an user editing call for proposals cannot use same title than other cfp' do
    event = create(:event, conference: @conference, title: "Title")
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    event2 = create(:event, conference: @conference, title: "Title2")
    create(:event_person, event: event2, person: @user.person, event_role: "submitter")
    create(:event_person, event: event2, person: @user.person, event_role: "speaker")

    visit '/'

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/#{event2.id}/edit"
    within '#cfp_form' do
      fill_in 'event[title]', with: event.title

      click_on 'Update Proposal'
    end

    assert_text 'There is already a session submitted with this title.'
  end

  test 'an user can edit a call for proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Update Proposal'
    end

    assert_text 'Your proposal was successfully updated.'
  end

  test 'an user can view their call of proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"
    assert_text event.title
  end


  test 'an user can delete a call for proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"

    click_on 'Delete'

    assert_text "Your proposal: '#{event.title}' has been deleted"
  end

  test 'a collaborator can edit their call for proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Update Proposal'
    end

    assert_text 'Your proposal was successfully updated.'
  end

  test 'a collaborator cannot delete their call for proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"

    assert_no_text 'Delete'
  end

  test 'collaborator recibes an email when user add your email in other collaborator' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

    within '#cfp_form' do
      check('event[instructions]', option: 'true')
      fill_in 'event[title]', with: 'Session Title'
      fill_in 'event[subtitle]', with: 'Subtitle Event'
      fill_in 'event[description]', with: 'Session description'
      fill_in 'event[other_presenters]', with: @person.email
      fill_in 'event[public_type]', with: 'Students'
      fill_in 'event[desired_outcome]', with: 'desired_outcome'
      fill_in 'event[phone_number]', with: 12345678
      select('Feature', from: 'event[track_id]')
      select('On the Frontlines', from: 'event[event_type]')
      choose '45 min'
      choose 'Yes'
      check('event[iff_before][]', option: '2018')
      check('event[code_of_conduct]', option: 'true')

      click_on 'Update Proposal'
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
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
