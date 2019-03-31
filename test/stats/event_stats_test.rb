require 'test_helper'

class EventStatsTest < ActiveSupport::TestCase
  setup do
    conference = create(:conference)

    populate!(conference)

    @event_stats = EventStats.new(conference)
  end

  test 'reports the total number of events' do
    expected_number_of_events = 6

    assert_equal expected_number_of_events, @event_stats.total_events
  end

  test 'reports the number of different event states' do
    expected_number_of_event_states = 5

    assert_equal expected_number_of_event_states, @event_stats.different_event_states
  end

  test 'reports the different event states breakdown' do
    expected_event_states_breakdown_without_void_values = {
      'new' => 1,
      'rejected' => 1,
      'canceled' => 1,
      'unconfirmed' => 1,
      'confirmed' => 2
    }

    assert_equal expected_event_states_breakdown_without_void_values, remove_voids_from(@event_stats.event_states_breakdown)
  end

  test 'reports the number of accepted events' do
    expected_number_of_accepted_events = 3

    assert_equal expected_number_of_accepted_events, @event_stats.total_accepted_events
  end

  test 'reports the number of confirmed events' do
    expected_number_of_confirmed_events = 2

    assert_equal expected_number_of_confirmed_events, @event_stats.total_confirmed_events
  end

  test 'reports the number of proposed speakers' do
    expected_number_of_proposed_speakers = 5

    assert_equal expected_number_of_proposed_speakers, @event_stats.total_proposed_speakers
  end

  test 'reports the number of confirmed speakers' do
    expected_number_of_confirmed_speakers = 3

    assert_equal expected_number_of_confirmed_speakers, @event_stats.total_confirmed_speakers
  end

  test 'reports the number of confirmed speakers holding a ticket' do
    expected_number_of_speakers_holding_ticket = 2

    assert_equal expected_number_of_speakers_holding_ticket, @event_stats.confirmed_speakers_holding_ticket
  end

  test 'reports the number of confirmed speakers not holding a ticket' do
    expected_number_of_speakers_not_holding_ticket = 1

    assert_equal expected_number_of_speakers_not_holding_ticket, @event_stats.confirmed_speakers_not_holding_ticket
  end

  test 'reports the number of confirmed events with first time speakers' do
    expected_number_of_events_with_first_time_speakers = 1

    assert_equal expected_number_of_events_with_first_time_speakers, @event_stats.confirmed_events_with_first_time_speakers
  end

  test 'reports the number of confirmed events with returning speakers' do
    expected_number_of_events_with_returning_speakers = 1

    assert_equal expected_number_of_events_with_returning_speakers, @event_stats.confirmed_events_with_returning_speakers
  end

  test 'reports the number of different confirmed event formats' do
    expected_number_of_event_formats = 2

    assert_equal expected_number_of_event_formats, @event_stats.different_confirmed_event_formats
  end

  test 'reports the different confirmed event formats breakdown' do
    expected_event_formats_breakdown_without_void_values = {
      'Workshop' => 1,
      'Feedback' => 1
    }

    assert_equal expected_event_formats_breakdown_without_void_values, remove_voids_from(@event_stats.confirmed_event_formats_breakdown)
  end

  test 'reports the number of different confirmed event themes' do
    expected_number_of_event_themes = 1

    assert_equal expected_number_of_event_themes, @event_stats.different_confirmed_event_themes
  end

  test 'reports the different confirmed event themes breakdown' do
    expected_event_themes_breakdown_without_void_values = {
      'Community Resilience' => 2
    }

    assert_equal expected_event_themes_breakdown_without_void_values, remove_voids_from(@event_stats.confirmed_event_themes_breakdown)
  end

  test 'reports the number of events with DIF request' do
    expected_number_of_requested_dif = 4

    assert_equal expected_number_of_requested_dif, @event_stats.events_with_dif_request
  end

  test 'reports the number of events with granted DIF request' do
    expected_number_of_granted_dif = 1

    assert_equal expected_number_of_granted_dif, @event_stats.events_with_granted_dif_request
  end

  test 'reports the number of confirmed events with DIF request' do
    expected_number_of_requested_dif = 2

    assert_equal expected_number_of_requested_dif, @event_stats.confirmed_events_with_dif_request
  end

  test 'reports the number of confirmed events with granted DIF request' do
    expected_number_of_granted_dif = 1

    assert_equal expected_number_of_granted_dif, @event_stats.confirmed_events_with_granted_dif_request
  end

  test 'reports the number of different gender options for confirmed speakers' do
    expected_number_of_gender_options = 3

    assert_equal expected_number_of_gender_options, @event_stats.different_gender_options_for_confirmed_speakers
  end

  test 'reports the different gender options breakdown for confirmed speakers' do
    expected_gender_options_breakdown_without_void_values = {
      'she' => 1,
      'ze/zir' => 1,
      nil => 1
    }

    assert_equal expected_gender_options_breakdown_without_void_values, remove_voids_from(@event_stats.gender_options_breakdown_for_confirmed_speakers)
  end

  test 'reports the number of different countries of origin for confirmed speakers' do
    expected_number_of_countries_of_origin = 3

    assert_equal expected_number_of_countries_of_origin, @event_stats.different_countries_of_origin_for_confirmed_speakers
  end

  test 'reports the different countries of origin breakdown for confirmed speakers' do
    expected_countries_of_origin_breakdown_without_void_values = {
      'Belize' => 1,
      'Canada' => 1,
      'Denmark' => 1
    }

    assert_equal expected_countries_of_origin_breakdown_without_void_values, remove_voids_from(@event_stats.countries_of_origin_breakdown_for_confirmed_speakers)
  end

  test 'reports the number of different professional backgrounds for confirmed speakers' do
    expected_number_of_professional_backgrounds = 3

    assert_equal expected_number_of_professional_backgrounds, @event_stats.different_professional_backgrounds_for_confirmed_speakers
  end

  test 'reports the different professional backgrounds breakdown for confirmed speakers' do
    expected_professional_backgrounds_breakdown_without_void_values = {
      'Research/Academia' => 1,
      'Data Science' => 2,
      'Frontline Activism' => 1
    }

    assert_equal expected_professional_backgrounds_breakdown_without_void_values, remove_voids_from(@event_stats.professional_backgrounds_breakdown_for_confirmed_speakers)
  end

  private

  def populate!(conference)
    talk_track = create(:track, name: 'Collaborative Talk')
    workshop_track = create(:track, name: 'Workshop')
    feedback_track = create(:track, name: 'Feedback')

    submitter = create(:person, country_of_origin: 'Armenia', professional_background: ['Digital Security Training', 'Frontline Activism', 'Research/Academia', 'Data Science'])
    another_submitter = create(:person, country_of_origin: 'Belize', professional_background: ['Digital Security Training', 'Frontline Activism'])

    new_event = create(:event, conference: conference, track: talk_track, event_type: 'Hacking the Net', travel_assistance: false, state: :new, iff_before: ['2015'])
    create(:event_person, event: new_event, person: submitter, event_role: :submitter)
    create(:event_person, event: new_event, person: submitter, event_role: :speaker)

    accepted_event = create(:event, conference: conference, track: feedback_track, event_type: 'The Next Net', travel_assistance: false, state: :unconfirmed, iff_before: ['2015'])
    create(:event_person, event: accepted_event, person: submitter, event_role: :submitter)
    create(:event_person, event: accepted_event, person: submitter, event_role: :speaker)

    rejected_event = create(:event, conference: conference, track: workshop_track, event_type: 'On the Frontlines', travel_assistance: true, state: :rejected, iff_before: ['Not Yet!'])
    create(:event_person, event: rejected_event, person: another_submitter, event_role: :submitter)
    create(:event_person, event: rejected_event, person: another_submitter, event_role: :speaker)

    canceled_event = create(:event, conference: conference, track: feedback_track, event_type: 'Journalism & Media', travel_assistance: true, state: :canceled, iff_before: ['Not Yet!'])
    create(:event_person, event: canceled_event, person: another_submitter, event_role: :submitter)
    create(:event_person, event: canceled_event, person: another_submitter, event_role: :speaker)

    presenter = create(:person, country_of_origin: 'Canada', professional_background: ['Research/Academia', 'Data Science'])
    another_presenter = create(:person, country_of_origin: 'Denmark', professional_background: ['Frontline Activism'])
    collaborator = create(:person, country_of_origin: 'Belize', professional_background: ['Data Science'])

    confirmed_event = create(:event, conference: conference, track: workshop_track, event_type: 'Community Resilience', travel_assistance: true, state: :confirmed, dif_status: 'Granted', iff_before: ['2015'])
    create(:event_person, event: confirmed_event, person: presenter, event_role: :submitter)
    create(:event_person, event: confirmed_event, person: presenter, event_role: :speaker)
    create(:event_person, event: confirmed_event, person: collaborator, event_role: :collaborator)

    another_confirmed_event = create(:event, conference: conference, track: feedback_track, event_type: 'Community Resilience', travel_assistance: true, state: :confirmed, iff_before: ['Not Yet!'])
    create(:event_person, event: another_confirmed_event, person: another_presenter, event_role: :submitter)
    create(:event_person, event: another_confirmed_event, person: another_presenter, event_role: :speaker)
    create(:event_person, event: confirmed_event, person: collaborator, event_role: :collaborator)

    create(:ticket, person: submitter, conference: conference, gender_pronoun: 'she', status: Ticket::COMPLETED)
    create(:ticket, person: another_submitter, conference: conference, gender_pronoun: 'he', status: Ticket::CANCELED)
    create(:ticket, person: presenter, conference: conference, gender_pronoun: 'she', status: Ticket::COMPLETED)
    create(:ticket, person: another_presenter, conference: conference, gender_pronoun: 'xey', status: Ticket::PENDING)
    create(:ticket, person: collaborator, conference: conference, gender_pronoun: 'ze/zir', status: Ticket::COMPLETED)
  end
end
