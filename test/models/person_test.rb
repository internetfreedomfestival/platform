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

    not_allowed = person.allowed_to_send_invites?

    assert_equal false, not_allowed
  end

  test '#allowed_to_send_invites? return false when person has been invited by a non admin' do
    person = create(:person)
    non_admin = create(:person, user: create(:user, role: 'submitter'))
    create(:invited, email: person.email, person: non_admin)

    not_allowed = person.allowed_to_send_invites?

    assert_equal false, not_allowed
  end

  test '#allowed_to_send_invites? return true when person has been invited by an admin' do
    person = create(:person)
    admin = create(:person, user: create(:user, role: 'admin'))
    create(:invited, email: person.email, person: admin)

    allowed = person.allowed_to_send_invites?

    assert_equal true, allowed
  end

  test 'knows people who has ticket for a conference' do
    conference = create(:conference)
    person_with_ticket = create(:person)
    create(:attendance_status, person: person_with_ticket, status: "Holds Ticket", conference: conference)
    person_without_ticket = create(:person)

    people_with_ticket = Person.with_ticket(conference)

    assert_equal 1, people_with_ticket.count
    assert_includes people_with_ticket, person_with_ticket
  end

  test 'knows dif confirmed people for a conference' do
    conference = create(:conference)
    submitter_with_dif_granted = create(:person)
    event = create(:event, travel_assistance: "true", dif_status: "Granted", conference: conference, recipient_travel_stipend: nil)
    create(:event_person, event: event, person: submitter_with_dif_granted, event_role: "submitter")
    create(:event_person, event: event, event_role: "collaborator")

    people_with_dif_granted = Person.with_dif_granted(conference)

    assert_equal 1, people_with_dif_granted.count
    assert_includes people_with_dif_granted, submitter_with_dif_granted
  end

  test 'knows recipient dif confirmed people for a conference' do
    conference = create(:conference)
    recipient_dif_granted = create(:person)
    event = create(:event, travel_assistance: "true", dif_status: "Granted", conference: conference, recipient_travel_stipend: recipient_dif_granted.email)

    people_with_dif_granted = Person.with_dif_travel_stipend_granted(conference)

    assert_equal 1, people_with_dif_granted.count
    assert_includes people_with_dif_granted, recipient_dif_granted
  end
end
