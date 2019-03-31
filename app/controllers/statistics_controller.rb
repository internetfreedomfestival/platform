class StatisticsController < ApplicationController
  before_action :authenticate_user!
  before_action :not_submitter!

  def events_by_state
    authorize! :read, @conference
    case params[:type]
    when 'lectures'
      result = @conference.events_by_state_and_type(:lecture)
    when 'workshops'
      result = @conference.events_by_state_and_type(:workshop)
    when 'others'
      remaining = Event::TYPES - [:workshop, :lecture]
      result = @conference.events_by_state_and_type(remaining)
    else
      result = @conference.events_by_state
    end

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def language_breakdown
    authorize! :read, @conference
    result = @conference.language_breakdown(params[:accepted_only])

    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def gender_breakdown
    authorize! :read, @conference
    result = @conference.gender_breakdown(params[:accepted_only])
    respond_to do |format|
      format.json { render json: result.to_json }
    end
  end

  def all_stats
    authorize! :administrate, Person

    # stats logic
    user_stats = UserStats.new
    attendee_stats = AttendeeStats.new(@conference)
    event_stats = EventStats.new(@conference)

    # output data
    output = OutputData.new

    output
      .add(['PLATFORM', nil])

    output
      .add_separator
      .add(['User Metrics', 'Users'])
      .add(['  Total users', user_stats.total_users])

    output
      .add(['Professional Background', 'Users'])
      user_stats.professional_backgrounds_breakdown.each do |background, users|
        output.add(["  #{background || 'N/A'}", users])
      end

    output
      .add(['Countries of Origin', 'Users'])
      user_stats.countries_of_origin_breakdown.each do |country, users|
        output.add(["  #{country || 'N/A'}", users])
      end

    output
      .add_separator
      .add(['CONFERENCE', nil])

    output
      .add_separator
      .add(['Attendee Metrics', 'Attendees'])
      .add(['  Total attendees', attendee_stats.total_attendees])
      .add(['  Are new attendees', attendee_stats.new_attendees])
      .add(['  Are returning attendees', attendee_stats.returning_attendees])
      .add(['  Are interested in volunteer', attendee_stats.total_volunteers])
      .add(['  Have requested DIF', attendee_stats.total_requested_dif])
      .add(['  Have been granted DIF', attendee_stats.total_granted_dif])
      .add(['  Have not been granted DIF', attendee_stats.total_pending_dif])
      .add(['  Have applied to be presenters', attendee_stats.total_speakers])
      .add(['  Are confirmed presenters', attendee_stats.total_confirmed_speakers])

    output
      .add(['Ticket Types', 'Attendees'])
      attendee_stats.ticket_types_breakdown.each do |ticket_type, attendees|
        output.add(["  #{ticket_type || 'N/A'}", attendees])
      end

    output
      .add(['Gender Balance', 'Attendees'])
      attendee_stats.gender_options_breakdown.each do |gender, attendees|
        output.add(["  #{gender || 'N/A'}", attendees])
      end

    output
      .add(['Professional Background', 'Attendees'])
      attendee_stats.professional_backgrounds_breakdown.each do |background, attendees|
        output.add(["  #{background || 'N/A'}", attendees])
      end

    output
      .add(['Countries of Origin', 'Attendees'])
      attendee_stats.countries_of_origin_breakdown.each do |country, attendees|
        output.add(["  #{country || 'N/A'}", attendees])
      end

    output
      .add_separator
      .add(['Session Metrics', 'Sessions'])
      .add(['  Proposed sessions', event_stats.total_events])
      .add(['  Accepted sessions', event_stats.total_accepted_events])
      .add(['  Confirmed sessions', event_stats.total_confirmed_events])
      .add(['  Confirmed sessions with DIF request', event_stats.confirmed_events_with_dif_request])
      .add(['  Confirmed sessions with granted DIF request', event_stats.confirmed_events_with_granted_dif_request])
      .add(['  Confirmed sessions with non-granted DIF request', event_stats.confirmed_events_with_pending_dif_request])
      .add(['  Confirmed sessions with first time presenters', event_stats.confirmed_events_with_first_time_speakers])
      .add(['  Confirmed sessions with returning presenters', event_stats.confirmed_events_with_returning_speakers])

    output
      .add(['Session States', 'Sessions'])
      event_stats.event_states_breakdown.each do |state, events|
        output.add(["  #{state || 'N/A'}", events])
      end

    output
      .add(['Session Formats', 'Sessions'])
      event_stats.confirmed_event_formats_breakdown.each do |format, events|
        output.add(["  #{format || 'N/A'}", events])
      end

    output
      .add(['Session Themes', 'Sessions'])
      event_stats.confirmed_event_themes_breakdown.each do |theme, events|
        output.add(["  #{theme || 'N/A'}", events])
      end

    output
      .add_separator
      .add(['Presenter Metrics', 'Presenters'])
      .add(['  Presenter applications', event_stats.total_proposed_speakers])
      .add(['  Total presenters', event_stats.total_confirmed_speakers])
      .add(['  Presenters holding ticket', event_stats.confirmed_speakers_holding_ticket])
      .add(['  Presenters not holding ticket', event_stats.confirmed_speakers_not_holding_ticket])

    output
      .add(['Gender Balance', 'Presenters'])
      event_stats.gender_options_breakdown_for_confirmed_speakers.each do |gender, presenters|
        output.add(["  #{gender || 'N/A'}", presenters])
      end

    output
      .add(['Professional Background', 'Presenters'])
      event_stats.professional_backgrounds_breakdown_for_confirmed_speakers.each do |background, presenters|
        output.add(["  #{background || 'N/A'}", presenters])
      end

    output
      .add(['Countries of Origin', 'Presenters'])
      event_stats.countries_of_origin_breakdown_for_confirmed_speakers.each do |country, presenters|
        output.add(["  #{country || 'N/A'}", presenters])
      end

    respond_to do |format|
      format.csv  { send_data output.to_csv, filename: "people-user-stats-#{Date.today}.csv" }
    end
  end

  class OutputData
    def initialize
      @data = []
    end

    def add(line)
      @data << line
      self
    end

    def add_separator
      add([nil, nil])
    end

    def to_csv
      CSV.generate do |csv|
        @data.each do |key, value|
          csv << [key, value]
        end
      end
    end
  end
  private_constant :OutputData
end
