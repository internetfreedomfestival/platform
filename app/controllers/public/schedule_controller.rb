class Public::ScheduleController < ApplicationController
  layout 'public_schedule'
  before_action :maybe_authenticate_user!

  def index
    redirect_to public_custom_path
  end

  def style
    respond_to do |format|
      format.css
    end
  end

  def custom
    @all_days = @conference.days
    @themes = Event::TYPES
    # Select first day if no button clicked
    if params.keys.include?("day")
      @day = @conference.days.find_by(id: params[:day])
    else
      @day = @conference.days.first
    end

    setup_day_ivars(@day)

    @days_events = []
    # Get Events for the day
    @events.each do |rooms, events|
      events.each do |event|
        @days_events << event
      end
    end
    # Sort events/day BY start time
    @days_events.sort! {|a,b| a.start_time <=> b.start_time}
    # Sort events/day/start time BY theme
    @themed_days = Hash.new([])
    @days_events.each do |event|
      @themed_days[event.event_type] += [event]
    end

    # arrange days by time
    @events_by_day_time = Hash.new { |k,v| k[v] = [] }
    @days_events.each do |event|
      @events_by_day_time[event.start_time].push(event) unless event.public_type == 'private'
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

  def day
    redirect_to public_custom_path
  end

  def events
    redirect_to public_custom_path
  end

  def event
    redirect_to public_custom_path
  end

  def speakers
    @speakers = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).order(:public_name, :first_name, :last_name)
    respond_to do |format|
      format.html
      format.json
      format.xls { render file: 'public/schedule/speakers.xls.erb', content_type: 'application/xls' }
    end
  end

  def speaker
    @speaker = Person.publicly_speaking_at(@conference.include_subs).confirmed(@conference.include_subs).find(params[:id])
  end

  def qrcode
    @qr = RQRCode::QRCode.new(public_schedule_index_url(format: :xml), size: 8, level: :h)
  end

  private

  def maybe_authenticate_user!
    authenticate_user! unless @conference.schedule_public
  end

  def setup_day_ivars(day)
    all_rooms = @conference.rooms_including_subs
    @rooms = []
    @events = {}
    @skip_row = {}
    all_rooms.each do |room|
      events = room.events.confirmed.is_public.scheduled_on(day).order(:start_time).to_a
      # Removed .no_conlicts from the above string to escape "Person availabilities model"
      next if events.empty?
      @events[room] = events
      @skip_row[room] = 0
      @rooms << room
    end
  end
end
