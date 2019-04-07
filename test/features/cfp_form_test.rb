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

    tracks = ['Collaborative Talk', 'Workshop', 'Panel Discussion', 'Feature', 'Feedback']
    tracks.each do |track|
      Track.create!(conference: @conference, name: track)
    end

    ActionMailer::Base.deliveries.clear
  end

  teardown do
    ActionMailer::Base.deliveries.clear
  end

  test 'CFP form link is enabled by FeatureToggle' do
    ENV['CURRENT_CONFERENCE'] = @conference.acronym

    login_as(@user)

    with_cfp_disabled do
      visit "/#{@conference.acronym}/cfp"
      assert_text /The #{@conference.alt_title}( Global)? Call for Proposals is now closed/
    end

    with_cfp_enabled do
      with_self_sessions_disabled do
        visit "/#{@conference.acronym}/cfp"
        assert_text "Submit a Session for the #{@conference.alt_title}"
      end
    end
  end

  test 'users can create a new session proposal' do
    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

  test 'users can create a new self-organized session proposal' do
    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Create Self-Organized Proposal'
      end

      assert_text 'Your proposal was successfully created.'
    end
  end

  test 'session proposals need required fields fullfilled' do
    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

  test 'self-organized session proposals need required fields fullfilled' do
    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Create Self-Organized Proposal'
      end

      assert_text "can't be blank"
    end
  end

  test 'a user cannot create two session proposals with the same title' do
    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

    test 'a user cannot create two self-organized session proposals with the same title' do
    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Create Self-Organized Proposal'
      end

      assert_text 'Your proposal was successfully created.'

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Create Self-Organized Proposal'
      end

      assert_text 'There is already a session submitted with this title.'
    end
  end

  test 'a user editing a session proposal cannot use same title of another proposal' do
    event = create(:event, conference: @conference, title: "Title")
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    event2 = create(:event, conference: @conference, title: "Title2")
    create(:event_person, event: event2, person: @user.person, event_role: "submitter")
    create(:event_person, event: event2, person: @user.person, event_role: "speaker")

    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event2.id}/edit"
      within '#cfp_form' do
        fill_in 'event[title]', with: event.title

        click_on 'Update Proposal'
      end

      assert_text 'There is already a session submitted with this title.'
    end
  end

  test 'a user editing a self-organized session proposals cannot use same title of another proposal' do
    event = create(:event, conference: @conference, title: "Title")
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    event2 = create(:event, conference: @conference, title: "Title2")
    create(:event_person, event: event2, person: @user.person, event_role: "submitter")
    create(:event_person, event: event2, person: @user.person, event_role: "speaker")

    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event2.id}/edit"
      within '#cfp_form' do
        fill_in 'event[title]', with: event.title

        click_on 'Update Self-Organized Proposal'
      end

      assert_text 'There is already a session submitted with this title.'
    end
  end

  test 'users can edit their session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

   test 'users can edit their self-organized session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Update Self-Organized Proposal'
      end

      assert_text 'Your proposal was successfully updated.'
    end
  end

  test 'users can view their session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    ENV['CURRENT_CONFERENCE'] = @conference.acronym

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"
    assert_text event.title
  end


  test 'users can delete their session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    ENV['CURRENT_CONFERENCE'] = @conference.acronym

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"

    click_on 'Delete'

    assert_text "Your proposal: '#{event.title}' has been deleted"
  end

  test 'collaborators can edit their session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

  test 'collaborators can edit their self-organized session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Update Self-Organized Proposal'
      end

      assert_text 'Your proposal was successfully updated.'
    end
  end

  test 'collaborators cannot delete their session proposals' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    login_as(@user)

    visit "/#{@conference.acronym}/cfp/person"

    assert_no_text 'Delete'
  end

  test 'collaborators receive an email when added to a session by other collaborator' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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
  end

  test 'collaborators receive an email when added to a self-organized session by other collaborator' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "collaborator")

    with_self_sessions_enabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
        fill_in 'event[desired_outcome]', with: 'desired_outcome'
        fill_in 'event[phone_number]', with: 12345678
        select('Feature', from: 'event[track_id]')
        select('Self-Organized', from: 'event[event_type]')
        choose '45 min'
        choose 'Yes'
        check('event[iff_before][]', option: '2018')
        check('event[code_of_conduct]', option: 'true')

        click_on 'Update Self-Organized Proposal'
      end

      assert_equal 1, ActionMailer::Base.deliveries.size
    end
  end

  test '[MIGRATION] new events have target audience field fulfilled' do
    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/new"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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

      @event = Event.last
      assert_equal @event.target_audience, 'Session for students'
    end
  end

  test '[MIGRATION] edited events have target audience field fulfilled' do
    event = create(:event, conference: @conference)
    create(:event_person, event: event, person: @user.person, event_role: "submitter")
    create(:event_person, event: event, person: @user.person, event_role: "speaker")

    with_self_sessions_disabled do
      login_as(@user)

      visit "/#{@conference.acronym}/cfp/events/#{event.id}/edit"

      within '#cfp_form' do
        check('event[instructions]', option: 'true')
        fill_in 'event[title]', with: 'Session Title'
        fill_in 'event[subtitle]', with: 'Subtitle Event'
        fill_in 'event[description]', with: 'Session description'
        fill_in 'event[other_presenters]', with: @person.email
        fill_in 'event[target_audience]', with: 'Session for students'
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

      @event = Event.last
      assert_equal @event.target_audience, 'Session for students'
    end
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
