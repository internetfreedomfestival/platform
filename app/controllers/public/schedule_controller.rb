class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!

  def index
    redirect_to public_custom_path
  end

  def custom
    search_terms = params[:terms]&.strip
    day_id = params[:day]

    @all_days = @conference.days

    days = [@all_days.first]
    days = [@all_days.find_by(id: day_id) || @all_days.first] if day_id
    days = @all_days if search_terms

    @events_by_day_and_time = {}

    all_rooms = @conference.rooms_including_subs
    all_events = {}

    days.each do |day|
      day_events = []
      all_rooms.each do |room|
        day_events += room.events.confirmed.is_public.scheduled_on(day).order(:start_time).to_a
      end
      all_events[day] = day_events
    end

    all_events.each do |day, events|
      # Filter events
      filter!(events, search_terms) if search_terms

      # Sort events/day by start time
      events.sort! {|a, b| a.start_time <=> b.start_time}

      # arrange days by time
      events_by_day_time = Hash.new { |k,v| k[v] = [] }
      events.each do |event|
        events_by_day_time[event.start_time].push(event) unless event.public_type == 'private'
      end

      @events_by_day_and_time[day] = events_by_day_time
    end
  end

  def custom_show
    @event = Event.find(params[:id])
    @presenter = @event.submitter
    @presenter_public_name = @presenter.tickets.find_by(conference: @event.conference)&.public_name
    @presenter_public_name = @presenter.first_name if @presenter_public_name.blank?
    @other_presenters_public_names = @event.other_presenters.split(',')
      .map { |email| Person.find_by('lower(email) = ?', email.downcase) }
      .map { |person| person&.tickets&.find_by(conference: @event.conference)&.public_name }
      .join(', ')
    @other_presenters_public_names = 'No other presenters' if @other_presenters_public_names.blank?
    @target_audience = @event.target_audience
    @target_audience = 'Not specified' if @target_audience.blank?
    @desired_outcome = @event.desired_outcome
    @desired_outcome = 'Not specified' if @desired_outcome.blank?
    @goal = @event.subtitle
    @goal = 'Not specified' if @goal.blank?
    @day_id = @event.conference.days.find { |day| @event.start_time >= day.start_date && @event.start_time <= day.end_date }&.id
  end

  private

  def maybe_authenticate_user!
    authenticate_user! unless @conference.schedule_public
  end

  def matches?(text, term)
    text =~ /#{Regexp.escape(term)}/i
  end

  def filter!(events, terms)
    terms.split.each do |term|
      events.select! do |event|
        matches?(event.title, term) ||
        matches?(event.event_type, term) ||
        matches?(event.room.name, term)
      end
    end
  end
end
