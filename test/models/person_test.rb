require 'test_helper'

class PersonTest < ActiveSupport::TestCase
  should validate_presence_of :email
  should have_many :availabilities
  should have_many :event_people
  should have_many :event_ratings
  should have_many :events
  should have_many :im_accounts
  should have_many :languages
  should have_many :links
  should have_many :phone_numbers
  should have_many :invites
  should have_many :attendance_statuses
  should have_many :tickets
  should have_one :dif
  should belong_to :user

  test '#full_name' do
    person = build(:person)
    assert_equal 'Fred Besen', person.full_name
    person = build(:person, first_name: 'Fred')
    assert_equal 'Fred Besen', person.full_name
    person = build(:person, first_name: 'Bred', last_name: 'Fesen')
    assert_equal 'Bred Fesen', person.full_name
  end

  test '#newer_than?' do
    old_person = create(:person)
    new_person = create(:person)
    refute old_person.newer_than?(new_person)
    assert new_person.newer_than?(old_person)
  end

  test '#role_state' do
    conference = create(:conference)
    event1 = create(:event, conference: conference)
    event2 = create(:event, conference: conference)
    event3 = create(:event, conference: conference)
    other_conference = create(:conference)
    other_event = create(:event, conference: other_conference)
    person = create(:person)
    create(:event_person, event: event1, person: person, event_role: :speaker, role_state: 'idea', created_at: Time.now - 10)
    create(:event_person, event: event2, person: person, event_role: :speaker, role_state: 'attending', created_at: Time.now - 5)
    create(:event_person, event: event3, person: person, event_role: :submitter, created_at: Time.now)
    create(:event_person, event: other_event, person: person, event_role: :speaker)
    assert_equal 'idea, attending', person.role_state(conference)
    assert_equal '', person.role_state(other_conference)
  end

  test '#set_role_state' do
    conference = create(:conference)
    event1 = create(:event, conference: conference)
    event2 = create(:event, conference: conference)
    person = create(:person)
    event_person1 = create(:event_person, event: event1, person: person, event_role: :speaker, role_state: 'idea')
    event_person2 = create(:event_person, event: event2, person: person, event_role: :submitter)
    person.set_role_state(conference, :attending)
    assert_equal 'attending', event_person1.reload.role_state
    assert_nil event_person2.reload.role_state
  end

  test 'feedback average gets calculated correctly' do
    conference = create(:conference)
    event1 = create(:event, conference: conference)
    event2 = create(:event, conference: conference)
    event3 = create(:event, conference: conference)
    person = create(:person)
    create(:event_person, event: event1, person: person, event_role: :speaker)
    create(:event_person, event: event2, person: person, event_role: :speaker)
    create(:event_person, event: event3, person: person, event_role: :speaker)

    create(:event_feedback, event: event1, rating: 3.0)
    create(:event_feedback, event: event2, rating: 4.0)
    assert_equal 3.5, person.average_feedback_as_speaker

    # FIXME doesn't register another feedback for event2, thus
    # using a new one
    create(:event_feedback, event: event3, rating: 5.0)
    assert_equal 4.0, person.average_feedback_as_speaker
  end

  test 'expenses get calculated correctly' do
    conference = create(:conference)
    person = create(:person)
    e1 = create(:expense, value: 11.0, conference: conference, reimbursed: false)
    e2 = create(:expense, value: 22.0, conference: conference, reimbursed: true)
    e3 = create(:expense, value: 33.0, conference: conference, reimbursed: true)
    person.expenses = [e1, e2, e3]
    assert_equal person.sum_of_expenses(conference, false), e1.value
    assert_equal person.sum_of_expenses(conference, true), e2.value + e3.value
  end

  # test 'persons merged correctly' do
  #   conference1 = create(:three_day_conference_with_events)
  #   conference2 = create(:three_day_conference_with_events)
  #
  #   user1 = create(:crew_user)
  #   user2 = create(:crew_user)
  #
  #   person1 = user1.person
  #   person2 = user2.person
  #
  #   ConferenceUser.create! user_id: user1.id, conference_id: conference1.id, role: 'orga'
  #   ConferenceUser.create! user_id: user2.id, conference_id: conference1.id, role: 'reviewer'
  #   ConferenceUser.create! user_id: user2.id, conference_id: conference2.id, role: 'coordinator'
  #
  #   assert_equal 2, User.count
  #   assert_equal 2, Person.count
  #   assert_equal 3, ConferenceUser.count
  #
  #   user3 = create(:crew_user)
  #   person3 = user3.person
  #   ConferenceUser.create! user_id: user3.id, conference_id: conference1.id, role: 'reviewer'
  #
  #   event1 = conference1.events.first
  #   event2 = conference2.events.first
  #   create(:confirmed_event_person, event: event1, person: person1)
  #   create(:confirmed_event_person, event: event2, person: person2)
  #   create(:confirmed_event_person, event: event2, person: person3)
  #
  #   person2.merge_with person1
  #
  #   assert_equal 2, User.count
  #   assert_equal 2, Person.count
  #   assert_equal 3, ConferenceUser.count
  #
  #   # check if the person2's user role for conference1 was properly up-merged to orga
  #   assert_equal 'orga', person2.user.conference_users.find_by(conference_id: conference1.id).role
  #
  #   # last updated person is person3, so it should be kept
  #   merged_person = person2.merge_with person3, keep_last_updated: true
  #
  #   assert_equal 1, User.count
  #   assert_equal 1, Person.count
  #   assert_equal 2, ConferenceUser.count
  #
  #   assert_equal merged_person, person3
  #   assert_equal 'orga', person3.user.conference_users.find_by(conference_id: conference1.id).role
  # end

  test 'different people can have same public name' do
    same_public_name = 'Helen'

    person = build(:person, public_name: same_public_name)
    other_person = build(:person, public_name: same_public_name)
    assert person.save
    assert other_person.save

    assert_equal person.public_name, other_person.public_name
  end

  test '#allowed_to_send_invites? return false when person has not been invited' do
    person = create(:person)
    conference = create(:conference)

    not_allowed = person.allowed_to_send_invites?(conference)

    assert_equal false, not_allowed
  end

  test '#allowed_to_send_invites? return false when the invitation does not allow sharing' do
    person = create(:person)
    conference = create(:conference)
    create(:invite, email: person.email, conference: conference, sharing_allowed: false)

    not_allowed = person.allowed_to_send_invites?(conference)

    assert_equal false, not_allowed
  end

  test '#allowed_to_send_invites? return true when the invitation does allow sharing' do
    person = create(:person)
    conference = create(:conference)
    create(:invite, email: person.email, conference: conference, sharing_allowed: true)

    with_user_invites_enabled do
      allowed = person.allowed_to_send_invites?(conference)
      assert_equal true, allowed
    end
  end

  test '#allowed_to_send_invites? return false when the feature flag is disabled' do
    person = create(:person)
    conference = create(:conference)
    create(:invite, email: person.email, conference: conference, sharing_allowed: true)

    with_user_invites_disabled do
      allowed = person.allowed_to_send_invites?(conference)
      assert_equal false, allowed
    end
  end

  test 'knows people who has ticket for a conference' do
    conference = create(:conference)
    person_with_ticket = create(:person)
    create(:attendance_status, person: person_with_ticket, status: 'Holds Ticket', conference: conference)
    create(:ticket, conference: conference, person: person_with_ticket)
    person_without_ticket = create(:person)

    people_with_ticket = Person.with_ticket(conference)

    assert_equal 1, people_with_ticket.count
    assert_includes people_with_ticket, person_with_ticket
  end

  test 'knows dif pending people for a conference' do
    conference = create(:conference)

    submitter_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: recipient_with_dif_pending.email)
    create(:event_person, event: event, person: submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_pending, event_role: 'collaborator')

    another_submitter_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: nil, conference: conference, recipient_travel_stipend: another_submitter_with_dif_pending.email)
    create(:event_person, event: event, person: another_submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    submitter_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')

    people_with_dif_pending = Person.with_dif_pending(conference)

    assert_equal 3, people_with_dif_pending.count
    assert_includes people_with_dif_pending, submitter_with_dif_pending
    assert_includes people_with_dif_pending, recipient_with_dif_pending
  end

  test 'knows dif granted people for a conference' do
    conference = create(:conference)

    submitter_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    another_submitter_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: another_submitter_with_dif_granted.email)
    create(:event_person, event: event, person: another_submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: recipient_with_dif_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_granted, event_role: 'collaborator')
    create(:event_person, event: event, event_role: 'collaborator')

    submitter_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')

    people_with_dif_granted = Person.with_dif_granted(conference)

    assert_equal 5, people_with_dif_granted.count
    assert_includes people_with_dif_granted, submitter_with_dif_granted
    assert_includes people_with_dif_granted, recipient_with_dif_granted
  end

  test 'knows people who requested dif for a conference' do
    conference = create(:conference)

    submitter_without_dif_request = create(:person)
    event = create(:event, conference: conference)
    create(:event_person, event: event, person: submitter_without_dif_request, event_role: 'submitter')

    submitter_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    another_submitter_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: another_submitter_with_dif_granted.email)
    create(:event_person, event: event, person: another_submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: recipient_with_dif_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_granted, event_role: 'collaborator')
    create(:event_person, event: event, event_role: 'collaborator')

    submitter_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference)
    create(:event_person, event: event, person: submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    another_submitter_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: another_submitter_with_dif_pending.email)
    create(:event_person, event: event, person: another_submitter_with_dif_pending, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_pending = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: recipient_with_dif_pending.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_pending, event_role: 'collaborator')
    create(:event_person, event: event, event_role: 'collaborator')

    submitter_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference)
    create(:event_person, event: event, person: submitter_with_dif_both_pending_and_granted, event_role: 'submitter')
    create(:event_person, event: event, event_role: 'collaborator')

    recipient_with_dif_both_pending_and_granted = create(:person)
    event = create(:event, travel_assistance: true, dif_status: 'Requested', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')
    event = create(:event, travel_assistance: true, dif_status: 'Granted', conference: conference, recipient_travel_stipend: recipient_with_dif_both_pending_and_granted.email)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: 'submitter')
    create(:event_person, event: event, person: recipient_with_dif_both_pending_and_granted, event_role: 'collaborator')

    people_with_dif_requested = Person.with_dif_requested(conference)

    assert_equal 8, people_with_dif_requested.count
  end

  test '.to_csv' do
    conference = create(:conference, acronym: 'IFF2019')

    person = create(:person)

    person_with_invitation_and_ticket = create(:person)
    invite_with_ticket = create(:invite, email: person_with_invitation_and_ticket.email, conference: conference, person: person)
    ticket = create(:ticket, conference: conference, person: person_with_invitation_and_ticket, status: "Completed")
    attendance_status = create(:attendance_status, conference: conference, person: person_with_invitation_and_ticket, status: 'Holds Ticket')

    person_with_invitation_and_event = create(:person)
    invite = create(:invite, email: person_with_invitation_and_event.email, conference: conference, person: person)
    event = create(:event, conference: conference, state: 'confirmed')
    create(:event_person, event: event, event_role: 'submitter', person: person_with_invitation_and_event)

    csv_content = Person.to_csv(conference)
    csv = CSV.parse(csv_content)

    IFF_ID, ATTENDANCE_STATUS, TICKET_STATUS, TICKET_ID, EMAIL, PGP_KEY, INVITED_BY, PUBLIC_NAME, FIRST_NAME, LAST_NAME, GENDER, GENDER_PRONOUN,
      COUNTRY, PROFESSIONAL_BACKGROUND, ORGANIZATION, PROJECT, TITLE, ATTENDED_BEFORE, CURRENT_SUBMITTER, CURRENT_PRESENTER,
      PREVIOUS_PRESENTER, GOALS, MAILING, MATTERMOST, VOLUNTEER \
      = (0..24).to_a

    headers = csv[0]
    assert_equal 'IFF ID', headers[IFF_ID]
    assert_equal 'Attendance Status', headers[ATTENDANCE_STATUS]
    assert_equal 'Ticket Status', headers[TICKET_STATUS]
    assert_equal 'Ticket ID', headers[TICKET_ID]
    assert_equal 'Email', headers[EMAIL]
    assert_equal 'PGP Key', headers[PGP_KEY]
    assert_equal 'Invited By', headers[INVITED_BY]
    assert_equal 'Public Name', headers[PUBLIC_NAME]
    assert_equal 'First Name', headers[FIRST_NAME]
    assert_equal 'Last Name', headers[LAST_NAME]
    assert_equal 'Gender', headers[GENDER]
    assert_equal 'Public Gender Pronoun', headers[GENDER_PRONOUN]
    assert_equal 'Country', headers[COUNTRY]
    assert_equal 'Professional Background', headers[PROFESSIONAL_BACKGROUND]
    assert_equal 'Organization', headers[ORGANIZATION]
    assert_equal 'Project', headers[PROJECT]
    assert_equal 'Title', headers[TITLE]
    assert_equal 'Attended IFF Before?', headers[ATTENDED_BEFORE]
    assert_equal 'Submitted Session', headers[CURRENT_SUBMITTER]
    assert_equal 'Presenter', headers[CURRENT_PRESENTER]
    assert_equal 'Presented Before?', headers[PREVIOUS_PRESENTER]
    assert_equal 'Main goals for attending the IFF?', headers[GOALS]
    assert_equal 'Include in Mailing', headers[MAILING]
    assert_equal 'Invite to Mattermost', headers[MATTERMOST]
    assert_equal 'Volunteeering Interest', headers[VOLUNTEER]

    first_row = csv[1]
    assert_equal person.id.to_s, first_row[IFF_ID]
    assert_nil first_row[ATTENDANCE_STATUS]
    assert_nil first_row[TICKET_STATUS]
    assert_nil first_row[TICKET_ID]
    assert_equal person.email, first_row[EMAIL]
    assert_nil first_row[PGP_KEY]
    assert_nil first_row[INVITED_BY]
    assert_nil first_row[PUBLIC_NAME]
    assert_equal person.first_name, first_row[FIRST_NAME]
    assert_equal person.last_name, first_row[LAST_NAME]
    assert_equal person.gender, first_row[GENDER]
    assert_nil first_row[GENDER_PRONOUN]
    assert_equal person.country_of_origin, first_row[COUNTRY]
    assert_equal person.professional_background.join(', '), first_row[PROFESSIONAL_BACKGROUND]
    assert_nil first_row[ORGANIZATION]
    assert_nil first_row[PROJECT]
    assert_nil first_row[TITLE]
    assert_nil first_row[ATTENDED_BEFORE]
    assert_equal 'No', first_row[CURRENT_SUBMITTER]
    assert_equal 'No', first_row[CURRENT_PRESENTER]
    assert_equal 'No', first_row[PREVIOUS_PRESENTER]
    assert_nil first_row[GOALS]
    assert_equal 'Yes', first_row[MAILING]
    assert_equal 'Yes', first_row[MATTERMOST]
    assert_equal 'No', first_row[VOLUNTEER]

    second_row = csv[2]
    assert_equal person_with_invitation_and_ticket.id.to_s, second_row[IFF_ID]
    assert_equal attendance_status.status, second_row[ATTENDANCE_STATUS]
    assert_equal ticket.status, second_row[TICKET_STATUS]
    assert_equal ticket.id.to_s, second_row[TICKET_ID]
    assert_equal person_with_invitation_and_ticket.email, second_row[EMAIL]
    assert_nil second_row[PGP_KEY]
    assert_equal invite_with_ticket.person.email, second_row[INVITED_BY]
    assert_equal ticket.public_name, second_row[PUBLIC_NAME]
    assert_equal person_with_invitation_and_ticket.first_name, second_row[FIRST_NAME]
    assert_equal person_with_invitation_and_ticket.last_name, second_row[LAST_NAME]
    assert_equal person_with_invitation_and_ticket.gender, second_row[GENDER]
    assert_equal ticket.gender_pronoun, second_row[GENDER_PRONOUN]
    assert_equal person_with_invitation_and_ticket.country_of_origin, second_row[COUNTRY]
    assert_equal person_with_invitation_and_ticket.professional_background.join(', '), second_row[PROFESSIONAL_BACKGROUND]
    assert_nil second_row[ORGANIZATION]
    assert_nil second_row[PROJECT]
    assert_nil second_row[TITLE]
    assert_equal ticket.iff_before.join(', '), second_row[ATTENDED_BEFORE]
    assert_equal 'No', second_row[CURRENT_SUBMITTER]
    assert_equal 'No', second_row[CURRENT_PRESENTER]
    assert_equal 'No', second_row[PREVIOUS_PRESENTER]
    assert_equal ticket.iff_goals.join(', '), second_row[GOALS]
    assert_equal 'Yes', second_row[MAILING]
    assert_equal 'Yes', second_row[MATTERMOST]
    assert_equal 'No', second_row[VOLUNTEER]

    third_row = csv[3]
    assert_equal person_with_invitation_and_event.id.to_s, third_row[IFF_ID]
    assert_nil third_row[ATTENDANCE_STATUS]
    assert_nil third_row[TICKET_STATUS]
    assert_nil third_row[TICKET_ID]
    assert_equal person_with_invitation_and_event.email, third_row[EMAIL]
    assert_nil third_row[PGP_KEY]
    assert_equal invite.person.email, third_row[INVITED_BY]
    assert_nil third_row[PUBLIC_NAME]
    assert_equal person_with_invitation_and_event.first_name, third_row[FIRST_NAME]
    assert_equal person_with_invitation_and_event.last_name, third_row[LAST_NAME]
    assert_equal person_with_invitation_and_event.gender, third_row[GENDER]
    assert_nil third_row[GENDER_PRONOUN]
    assert_equal person_with_invitation_and_event.country_of_origin, third_row[COUNTRY]
    assert_equal person_with_invitation_and_event.professional_background.join(', '), third_row[PROFESSIONAL_BACKGROUND]
    assert_nil third_row[ORGANIZATION]
    assert_nil third_row[PROJECT]
    assert_nil third_row[TITLE]
    assert_nil third_row[ATTENDED_BEFORE]
    assert_equal 'Yes', third_row[CURRENT_SUBMITTER]
    assert_equal 'Yes', third_row[CURRENT_PRESENTER]
    assert_equal 'No', third_row[PREVIOUS_PRESENTER]
    assert_nil third_row[GOALS]
    assert_equal 'Yes', third_row[MAILING]
    assert_equal 'Yes', third_row[MATTERMOST]
    assert_equal 'No', third_row[VOLUNTEER]
  end
end
