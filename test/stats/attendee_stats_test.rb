require 'test_helper'

class AttendeeStatsTest < ActiveSupport::TestCase
  setup do
    conference = create(:conference)

    populate!(conference)

    @attendee_stats = AttendeeStats.new(conference)
  end

  test 'reports the total number of attendees' do
    expected_number_of_attendees = 5

    assert_equal expected_number_of_attendees, @attendee_stats.total_attendees
  end

  test 'reports the number of new attendees' do
    expected_number_of_new_attendees = 2

    assert_equal expected_number_of_new_attendees, @attendee_stats.new_attendees
  end

  test 'reports the number of returning attendees' do
    expected_number_of_returning_attendees = 3

    assert_equal expected_number_of_returning_attendees, @attendee_stats.returning_attendees
  end

  test 'reports the number of different ticket types' do
    expected_number_of_ticket_types = 3

    assert_equal expected_number_of_ticket_types, @attendee_stats.different_ticket_types
  end

  test 'reports the different ticket types breakdown' do
    expected_ticket_types_breakdown = {
      Ticket::INDIVIDUAL => 2,
      Ticket::SOLIDARITY => 2,
      Ticket::ORGANIZATIONAL => 1
    }

    assert_equal expected_ticket_types_breakdown, @attendee_stats.ticket_types_breakdown
  end

  test 'reports the number of attendees which have requested DIF' do
    expected_number_of_requested_dif = 2

    assert_equal expected_number_of_requested_dif, @attendee_stats.total_requested_dif
  end

  test 'reports the number of attendees with pending DIF' do
    expected_number_of_pending_dif = 1

    assert_equal expected_number_of_pending_dif, @attendee_stats.total_pending_dif
  end

  test 'reports the number of attendees with granted DIF' do
    expected_number_of_granted_dif = 1

    assert_equal expected_number_of_granted_dif, @attendee_stats.total_granted_dif
  end

  test 'reports the number of attendees interested in volunteer' do
    expected_number_of_interested_in_volunteer = 3

    assert_equal expected_number_of_interested_in_volunteer, @attendee_stats.total_volunteers
  end

  test 'reports the number of attendees which are proposed speakers' do
    expected_number_of_proposed_speakers = 4

    assert_equal expected_number_of_proposed_speakers, @attendee_stats.total_speakers
  end

  test 'reports the number of attendees which are confirmed speakers' do
    expected_number_of_confirmed_speakers = 3

    assert_equal expected_number_of_confirmed_speakers, @attendee_stats.total_confirmed_speakers
  end

  test 'reports the number of different gender options for the attendees' do
    expected_number_of_gender_options = 4

    assert_equal expected_number_of_gender_options, @attendee_stats.different_gender_options
  end

  test 'reports the different gender options breakdown for the attendees' do
    expected_gender_options_breakdown_without_void_values = {
      've/ver' => 1,
      'she' => 2,
      'he' => 1,
      'ze/zir' => 1
    }

    assert_equal expected_gender_options_breakdown_without_void_values, remove_voids_from(@attendee_stats.gender_options_breakdown)
  end

  test 'reports the number of different countries of origin for the attendees' do
    expected_number_of_countries_of_origin = 4

    assert_equal expected_number_of_countries_of_origin, @attendee_stats.different_countries_of_origin
  end

  test 'reports the different countries of origin breakdown for the attendees' do
    expected_countries_of_origin_breakdown_without_void_values = {
      'Armenia' => 1,
      'Belize' => 2,
      'Canada' => 1,
      'Denmark' => 1
    }

    assert_equal expected_countries_of_origin_breakdown_without_void_values, remove_voids_from(@attendee_stats.countries_of_origin_breakdown)
  end

  test 'reports the number of different professional backgrounds for the attendees' do
    expected_number_of_professional_backgrounds = 5

    assert_equal expected_number_of_professional_backgrounds, @attendee_stats.different_professional_backgrounds
  end

  test 'reports the different professional backgrounds breakdown for the attendees' do
    expected_professional_backgrounds_breakdown_without_void_values = {
      'Digital Security Training' => 1,
      'Frontline Activism' => 2,
      'Research/Academia' => 1,
      'Data Science' => 2,
      'Journalism and Media' => 1
    }

    assert_equal expected_professional_backgrounds_breakdown_without_void_values, remove_voids_from(@attendee_stats.professional_backgrounds_breakdown)
  end

  private

  def populate!(conference)
    confirmed_event = create(:event, conference: conference, state: :confirmed, travel_assistance: false)
    confirmed_event_granted_dif = create(:event, conference: conference, state: :confirmed, travel_assistance: true, dif_status: 'Granted')
    rejected_event = create(:event, conference: conference, state: :rejected, travel_assistance: false)
    rejected_event_pending_dif = create(:event, conference: conference, state: :rejected, travel_assistance: true, dif_status: 'Requested')

    person = create(:person,
      country_of_origin: 'Armenia',
      professional_background: ['Digital Security Training', 'Frontline Activism', 'Research/Academia', 'Data Science'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::CANCELED,
      iff_before: ['Not yet!'],
      gender_pronoun: 've/ver',
      interested_in_volunteer: true,
      ticket_option: Ticket::INDIVIDUAL)
    create(:event_person, event: confirmed_event, person: person, event_role: :collaborator)

    person = create(:person,
      country_of_origin: 'Belize',
      professional_background: ['Digital Security Training', 'Frontline Activism'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::COMPLETED,
      iff_before: ['Not yet!'],
      gender_pronoun: 've/ver',
      interested_in_volunteer: true,
      ticket_option: Ticket::INDIVIDUAL)
    create(:event_person, event: confirmed_event, person: person, event_role: :submitter)
    create(:event_person, event: confirmed_event, person: person, event_role: :speaker)

    person = create(:person,
      country_of_origin: 'Canada',
      professional_background: ['Research/Academia', 'Data Science'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::COMPLETED,
      iff_before: ['Not yet!'],
      gender_pronoun: 'she',
      interested_in_volunteer: false,
      ticket_option: Ticket::INDIVIDUAL)
    create(:event_person, event: confirmed_event, person: person, event_role: :collaborator)
    create(:event_person, event: rejected_event, person: person, event_role: :collaborator)

    person = create(:person,
      country_of_origin: 'Denmark',
      professional_background: ['Frontline Activism'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::COMPLETED,
      iff_before: ['2016', '2018'],
      gender_pronoun: 'she',
      interested_in_volunteer: true,
      ticket_option: Ticket::SOLIDARITY)
    create(:event_person, event: confirmed_event, person: person, event_role: :collaborator)
    create(:event_person, event: confirmed_event_granted_dif, person: person, event_role: :submitter)
    create(:event_person, event: confirmed_event_granted_dif, person: person, event_role: :speaker)

    person = create(:person,
      country_of_origin: 'Belize',
      professional_background: ['Data Science'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::COMPLETED,
      iff_before: ['2017'],
      gender_pronoun: 'he',
      interested_in_volunteer: false,
      ticket_option: Ticket::SOLIDARITY)
    create(:event_person, event: rejected_event, person: person, event_role: :collaborator)
    create(:event_person, event: rejected_event_pending_dif, person: person, event_role: :collaborator)

    person = create(:person,
      country_of_origin: 'Armenia',
      professional_background: ['Journalism and Media'])
    create(:ticket,
      person: person,
      conference: conference,
      status: Ticket::COMPLETED,
      iff_before: ['2018'],
      gender_pronoun: 'ze/zir',
      interested_in_volunteer: true,
      ticket_option: Ticket::ORGANIZATIONAL)

    person = create(:person,
      country_of_origin: 'Canada',
      professional_background: ['Journalism and Media', 'Data Science'])
    create(:event_person, event: confirmed_event, person: person, event_role: :collaborator)
    create(:event_person, event: rejected_event_pending_dif, person: person, event_role: :submitter)
    create(:event_person, event: rejected_event_pending_dif, person: person, event_role: :speaker)

    person = create(:person,
      country_of_origin: 'Denmark',
      professional_background: ['Research/Academia', 'Frontline Activism'])
    create(:event_person, event: rejected_event, person: person, event_role: :submitter)
    create(:event_person, event: rejected_event, person: person, event_role: :speaker)
  end
end
