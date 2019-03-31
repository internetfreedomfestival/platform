class EventStats
  include StatsHelpers

  def initialize(conference)
    @conference = conference
  end

  def total_events
    @total_events ||= events.count
  end

  def events_with_dif_request
    @events_with_dif_request ||= events.where(travel_assistance: true).count
  end

  def events_with_granted_dif_request
    @events_with_granted_dif_request ||= events.where(travel_assistance: true, dif_status: 'Granted').count
  end

  def events_with_pending_dif_request
    @events_with_pending_dif_request ||= events_with_dif_request - events_with_granted_dif_request
  end

  def different_event_states
    @different_event_states ||= events.distinct.select(:state).count
  end

  def event_states_breakdown
    @event_states_breakdown ||= build_breakdown(events.group(:state).count, Event::STATES)
  end

  def total_accepted_events
    @total_accepted_events ||= accepted_events.count
  end

  def total_confirmed_events
    @total_confirmed_events ||= confirmed_events.count
  end

  def confirmed_events_with_first_time_speakers
    @confirmed_events_with_first_time_speakers ||= confirmed_events.where('iff_before LIKE ?', '%Not yet!%').count
  end

  def confirmed_events_with_returning_speakers
    @confirmed_events_with_returning_speakers ||= total_confirmed_events - confirmed_events_with_first_time_speakers
  end

  def different_confirmed_event_formats
    @different_confirmed_event_formats ||= confirmed_events.distinct.select(:track_id).count
  end

  def confirmed_event_formats_breakdown
    @confirmed_event_formats_breakdown ||= build_breakdown(confirmed_events.joins('LEFT JOIN "tracks" ON "tracks"."id" = "events"."track_id"').group('tracks.name').count, Track.where(conference: @conference).map(&:name).uniq)
  end

  def different_confirmed_event_themes
    @different_confirmed_event_themes ||= confirmed_events.distinct.select(:event_type).count
  end

  def confirmed_event_themes_breakdown
    @confirmed_event_themes_breakdown ||= build_breakdown(confirmed_events.group(:event_type).count, Event.where(conference: @conference).map(&:event_type).uniq)
  end

  def confirmed_events_with_dif_request
    @confirmed_events_with_dif_request ||= confirmed_events.where(travel_assistance: true).count
  end

  def confirmed_events_with_granted_dif_request
    @confirmed_events_with_granted_dif_request ||= confirmed_events.where(travel_assistance: true, dif_status: 'Granted').count
  end

  def confirmed_events_with_pending_dif_request
    @confirmed_events_with_pending_dif_request ||= confirmed_events_with_dif_request - confirmed_events_with_granted_dif_request
  end

  def total_proposed_speakers
    @total_proposed_speakers ||= proposed_speakers.distinct.count
  end

  def total_confirmed_speakers
    @total_confirmed_speakers ||= confirmed_speakers.count
  end

  def confirmed_speakers_holding_ticket
    @confirmed_speakers_holding_ticket ||= confirmed_speakers.with_ticket(@conference).count
  end

  def confirmed_speakers_not_holding_ticket
    @confirmed_speakers_not_holding_ticket ||= total_confirmed_speakers - confirmed_speakers_holding_ticket
  end

  def different_gender_options_for_confirmed_speakers
    @different_gender_options_for_confirmed_speakers ||= gender_options.uniq.size
  end

  def gender_options_breakdown_for_confirmed_speakers
    @gender_options_breakdown_for_confirmed_speakers ||= build_breakdown(gender_options.group_by(&:itself).transform_values(&:size), Person::GENDER_PRONOUN)
  end

  def different_countries_of_origin_for_confirmed_speakers
    @different_countries_of_origin_for_confirmed_speakers ||= confirmed_speakers.select(:country_of_origin).count
  end

  def countries_of_origin_breakdown_for_confirmed_speakers
    @countries_of_origin_breakdown_for_confirmed_speakers ||= build_breakdown(confirmed_speakers.group(:country_of_origin).count, Person::COUNTRIES)
  end

  def different_professional_backgrounds_for_confirmed_speakers
    @different_professional_backgrounds_for_confirmed_speakers ||= professional_backgrounds.uniq.size
  end

  def professional_backgrounds_breakdown_for_confirmed_speakers
    @professional_backgrounds_breakdown_for_confirmed_speakers ||= build_breakdown(professional_backgrounds.group_by(&:itself).transform_values(&:size), Person::PROFESSIONAL_BACKGROUND)
  end

  private

  def events
    @events ||= Event.where(conference: @conference)
  end

  def accepted_events
    @accepted_events ||= events.accepted
  end

  def confirmed_events
    @confirmed_events ||= events.confirmed
  end

  def proposed_speakers
    @proposed_speakers ||= Person.involved_in(@conference).where(event_people: { event_role: EventPerson::SPEAKER })
  end

  def confirmed_speakers
    @confirmed_speakers ||= Person.speaking_at(@conference)
  end

  def gender_options
    @gender_options = Ticket.where(conference: @conference, person: confirmed_speakers, status: Ticket::COMPLETED).pluck(:gender_pronoun) + ([nil] * confirmed_speakers_not_holding_ticket)
  end

  def professional_backgrounds
    @professional_backgrounds ||= confirmed_speakers.pluck(:professional_background).flatten.reject(&:blank?)
  end
end
